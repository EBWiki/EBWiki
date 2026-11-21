# frozen_string_literal: true

module PhotoSearch
  module ReviewDatabaseConnection
    module_function

    def with_url(url)
      previous_url = ENV.fetch('DATABASE_URL', nil)
      apply_url(url)
      yield ActiveRecord::Base.connection
    ensure
      restore_url(previous_url)
    end

    def apply_url(url)
      ENV['DATABASE_URL'] = url
      ActiveRecord::Base.establish_connection(url)
    end

    def restore_url(previous_url)
      if previous_url.nil?
        ENV.delete('DATABASE_URL')
      else
        ENV['DATABASE_URL'] = previous_url
      end
      ActiveRecord::Base.establish_connection
    end
  end
end
