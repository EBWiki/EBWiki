# frozen_string_literal: true

# Clears stale Neon/PgBouncer prepared-statement caches before review seeding.
module ReviewDbConnection
  module_function

  def reset_pool!
    pool = ActiveRecord::Base.connection_pool
    pool.connection.clear_cache! if pool.connected?
  rescue StandardError
    nil
  ensure
    ActiveRecord::Base.connection_handler.clear_all_connections!
    ActiveRecord::Base.establish_connection
  end
end
