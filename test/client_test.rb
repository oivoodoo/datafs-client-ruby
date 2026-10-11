require "minitest/autorun"
require "socket"
require "json"
require_relative "../lib/datafs"

class ClientTest < Minitest::Test
  def test_timeseries_sends_bearer_and_query
    server = TCPServer.new("127.0.0.1", 0)
    port = server.addr[1]
    thread = Thread.new do
      sock = server.accept
      req = +""
      while (line = sock.gets)
        req << line
        break if line == "\r\n"
      end
      body = '{"from":"2026-09-12","to":"2026-10-11","interval":"day","totals":{"visitors":4}}'
      sock.write "HTTP/1.1 200 OK\r\ncontent-type: application/json\r\ncontent-length: #{body.bytesize}\r\nconnection: close\r\n\r\n#{body}"
      sock.close
      req
    end

    client = Datafs::Client.new("http://127.0.0.1:#{port}", "secret")
    series = client.timeseries("site-1", "2026-09-12", "2026-10-11")
    raw = thread.value
    assert_includes raw, "GET /api/v1/sites/site-1/timeseries?"
    assert_includes raw, "from=2026-09-12"
    assert_includes raw, "Authorization: Bearer secret"
    assert_equal 4, series["totals"]["visitors"]
  ensure
    server.close
  end
end
