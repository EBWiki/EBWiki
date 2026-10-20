# frozen_string_literal: true

require_relative 'context_matcher'
require_relative 'mugshot_filter'
require_relative 'openverse_client'
require_relative 'query_builder'
require_relative 'wikimedia_commons_client'

module PhotoFinder
  class Search
    DEFAULT_CLIENTS = [
      WikimediaCommonsClient.new,
      OpenverseClient.new
    ].freeze

    def initialize(case_record, clients: DEFAULT_CLIENTS)
      @case_record = case_record
      @clients = clients
    end

    def call
      query = QueryBuilder.build(@case_record)
      return [] if query.blank?

      @clients
        .flat_map { |client| client.search(query, case_record: @case_record) }
        .reject { |candidate| MugshotFilter.mugshot?(candidate) }
        .select { |candidate| ContextMatcher.matches?(candidate, @case_record) }
        .uniq(&:image_url)
    end
  end
end
