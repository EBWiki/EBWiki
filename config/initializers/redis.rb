# frozen_string_literal: true

# config/initializers/redis.rb

if Rails.env.test?
  $redis = Redis::Namespace.new('ebwiki', redis: MockRedis.new)
else
  $redis = Redis::Namespace.new('ebwiki', redis: Redis.new(host: ENV['REDISTOGO_URL'] || 'localhost', port: 6379, db: 0))
end
