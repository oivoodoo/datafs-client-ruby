# datafs-client

Ruby client for a self-hosted DataFS install. MIT. Standard library only.

```ruby
client = Datafs::Client.new("https://analytics.example.com", ENV.fetch("DATAFS_API_KEY"))
series = client.timeseries(site_id, "2026-09-12", "2026-10-11")
event_id = client.server_event(domain: "example.com", name: "signup")
```

See `API.md`.

```
ruby test/client_test.rb
```
