# frozen_string_literal: true

# config/initializers/redis.rb

$redis = if Rails.env.test?
           Redis::Namespace.new('ebwiki',
                                redis: MockRedis.new,
                                driver: :hiredis)
         else
           Redis::Namespace.new('ebwiki',
                                redis: Redis.new(url: ENV.fetch('REDIS_URL', nil),
                                                 driver: :hiredis))
         end
