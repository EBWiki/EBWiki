# frozen_string_literal: true

# config/initializers/redis.rb

$redis = if Rails.env.test?
  Redis::Namespace.new('ebwiki', redis: MockRedis.new)
elsif Rails.env.production?
  Redis::Namespace.new('ebwiki', redis: Redis.new(url: ENV['REDISTOGO_URL']))
else
  Redis::Namespace.new('ebwiki', redis: Redis.new('localhost',
                                                 port: 6379,
                                                 db: 0))
 end
