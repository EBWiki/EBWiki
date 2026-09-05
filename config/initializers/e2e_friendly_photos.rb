# frozen_string_literal: true

# Playwright boots the Rails test server on 127.0.0.1. Allow that host and
# keep Searchkick from failing the run when Elasticsearch is unused.
if ENV['E2E_STUB_WIKIMEDIA'] == '1'
  Rails.application.config.hosts << '127.0.0.1'
  Rails.application.config.hosts << 'localhost'
  Searchkick.disable_callbacks if defined?(Searchkick)
  Geocoder.configure(lookup: :test)
  Geocoder::Lookup::Test.set_default_stub(
    [{ 'latitude' => 42.6525793, 'longitude' => -73.7562317 }]
  )
end
