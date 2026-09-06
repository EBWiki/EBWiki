# frozen_string_literal: true

# Clears stale Neon/PgBouncer prepared-statement caches before review seeding.
module ReviewDbConnection
  module_function

  def reset_pool!
    ActiveRecord::Base.clear_query_caches_for_current_thread
    clear_connected_cache!
  rescue StandardError
    nil
  ensure
    ActiveRecord::Base.connection_handler.clear_all_connections!
    ActiveRecord::Base.establish_connection
  end

  def with_pooler_retry
    yield
  rescue ActiveRecord::StatementInvalid => e
    raise unless cached_plan_error?(e)

    reset_pool!
    yield
  end

  def cached_plan_error?(error)
    return true if pg_cached_plan?(error.cause)
    return true if error.is_a?(ActiveRecord::PreparedStatementCacheExpired)

    error.message.include?('cached plan must not change result type')
  end

  def pg_cached_plan?(cause)
    cause.is_a?(PG::FeatureNotSupported) && cause.message.to_s.include?('cached plan')
  end

  def clear_connected_cache!
    pool = ActiveRecord::Base.connection_pool
    pool.connection.clear_cache! if pool.connected?
  end
end
