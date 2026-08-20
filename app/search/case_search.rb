# frozen_string_literal: true

# Postgres full-text search for cases (pg_search / tsv).
class CaseSearch
  PER_PAGE = 12
  MATCH_ALL = '*'

  attr_reader :query, :options

  def initialize(query: nil, options: {})
    @query = normalize_query(query)
    @options = options
  end

  def call
    scope = Case.all
    scope = scope.search_text(query) if query
    scope = scope.where(state_id: options[:state_id]) if options[:state_id].present?
    scope = scope.order(date: :desc)
    scope.includes(:state).page(options[:page]).per(PER_PAGE)
  end

  private

  def normalize_query(value)
    text = value.to_s.strip
    return if text.blank? || text == MATCH_ALL

    text
  end
end
