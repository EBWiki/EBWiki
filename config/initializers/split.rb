# frozen_string_literal: true

# from tutorial https://github.com/splitrb/split/wiki/Use-Split-with-Heroku-RedisToGo

Split.configure do |config|
  # config.robot_regex = /my_custom_robot_regex/ # Should set it
  # config.ignore_ip_addresses << '81.19.48.130'. You should set it using SettingsLogic or something
  config.db_failover = true # handle redis errors gracefully
  config.db_failover_on_db_error = proc { |error| Rails.logger.error(error.message) }
  config.allow_multiple_experiments = true # It's fine for me, but might not for you
  config.enabled = !Rails.env.test?
end

# Split::Dashboard.use Rack::Auth::Basic do |username, password|
#   username == ENV["SPLIT_USERNAME"] && password == ENV["SPLIT_PASSWORD"]
# end

if ENV['REDISTOGO_URL']
  uri = URI.parse(ENV['REDISTOGO_URL'])
  namespace = ['split', 'ebw', Rails.env].join(':')

  redis = Redis.new(host: uri.host,
                    port: uri.port,
                    password: uri.password,
                    thread_safe: true)

  redis_namespace = Redis::Namespace.new(namespace, redis: redis)

  Split.redis = redis_namespace
end
