# frozen_string_literal: true

module PhotoSearch
  # Reads published case rows from staging Postgres after the scrubbed ebwiki-review load.
  module StagingCaseLoader
    EXPECTED_CASE_COUNT = 4033

    CaseRow = Data.define(
      :id, :slug, :title, :city, :state, :date, :avatar, :default_avatar_url, :latitude, :longitude
    )

    CASE_SELECT = <<~SQL.squish
      SELECT id, slug, title, city, state, date, avatar, default_avatar_url, latitude, longitude
      FROM cases
      ORDER BY id
    SQL

    class << self
      def case_count(connection: ActiveRecord::Base.connection)
        connection.select_value('SELECT COUNT(*) FROM cases').to_i
      end

      def report(connection: ActiveRecord::Base.connection)
        count = case_count(connection: connection)
        {
          case_count: count,
          expected_case_count: EXPECTED_CASE_COUNT,
          matches_expected: count == EXPECTED_CASE_COUNT
        }
      end

      def each_case(connection: ActiveRecord::Base.connection, batch_size: 500, &)
        unless block_given?
          return enum_for(:each_case, connection: connection, batch_size: batch_size)
        end

        paginate_cases(connection, batch_size, &)
      end

      def paginate_cases(connection, batch_size, &)
        offset = 0
        limit = batch_size.to_i
        loop do
          rows = connection.select_all("#{CASE_SELECT} LIMIT #{limit} OFFSET #{offset.to_i}")
          break if rows.empty?

          rows.each { |row| yield CaseRow.new(**row.symbolize_keys) }
          offset += limit
        end
      end
    end
  end
end
