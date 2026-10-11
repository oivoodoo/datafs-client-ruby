require "json"
require "net/http"
require "uri"

module Datafs
  class Error < StandardError
    attr_reader :status, :code, :message

    def initialize(status, code, message)
      super(message.to_s.empty? ? code : "#{code}: #{message}")
      @status = status
      @code = code
      @message = message
    end
  end

  class Client
    def initialize(base_url, api_key, timeout: 15)
      @base_url = base_url.sub(%r{/\z}, "")
      @api_key = api_key
      @timeout = timeout
    end

    def version
      request("GET", "/api/v1/version")
    end

    def server_event(event)
      request("POST", "/api/v1/server-event", body: compact(event))["event_id"]
    end

    def timeseries(site_id, from, to, interval = "day")
      request("GET", "/api/v1/sites/#{site_id}/timeseries", query: { from: from, to: to, interval: interval })
    end

    def breakdown(site_id, from, to, dimension, limit: 100, country: nil)
      query = { from: from, to: to, dimension: dimension, limit: limit }
      query[:country] = country if country && !country.empty?
      request("GET", "/api/v1/sites/#{site_id}/breakdown", query: query)
    end

    def realtime(site_id)
      request("GET", "/api/v1/sites/#{site_id}/realtime")
    end

    def funnel(site_id, day, steps)
      request("POST", "/api/v1/sites/#{site_id}/funnel", body: { day: day, steps: steps })
    end

    private

    def compact(event)
      event.reject { |_, value| value.nil? || value == "" || (value.respond_to?(:empty?) && value.empty?) }
    end

    def request(method, path, query: nil, body: nil)
      uri = URI(@base_url + path)
      uri.query = URI.encode_www_form(query) if query
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @timeout
      http.read_timeout = @timeout
      req = Net::HTTP.const_get(method.capitalize).new(uri)
      req["Authorization"] = "Bearer #{@api_key}" if @api_key && !@api_key.empty?
      req["Accept"] = "application/json"
      if body
        req["Content-Type"] = "application/json"
        req.body = JSON.generate(body)
      end
      res = http.request(req)
      if res.code.to_i >= 400
        payload = res.body.to_s.empty? ? {} : JSON.parse(res.body)
        raise Error.new(res.code.to_i, payload["error"] || res.code, payload["message"])
      end
      return nil if res.body.nil? || res.body.empty?

      JSON.parse(res.body)
    end
  end
end
