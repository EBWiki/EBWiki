# frozen_string_literal: true

# config/initializers/geocoder.rb
geocoder_config = {
  # geocoding service (see below for supported options):
  # lookup: :yandex,
  # IP address geocoding service (see below for supported options):
  ip_lookup: :maxmind,
  # to use an API key:
  api_key: ENV.fetch('GOOGLE_MAPS_API_KEY', nil),
  # geocoding service request timeout, in seconds (default 3):
  timeout: 5,
  # set default units to kilometers:
  units: :mi
  # caching (see below for details):
  # cache: Redis.new,
  # cache_prefix: '...'
}
# CI / e2e seeds should not call an external geocoder.
geocoder_config[:lookup] = :test if ENV['SKIP_GEOCODE'].present?

Geocoder.configure(geocoder_config)
