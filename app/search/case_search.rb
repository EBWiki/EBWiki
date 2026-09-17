# frozen_string_literal: true

# Functionality to dynamically search cases via Postgres full-text search.
class CaseSearch
  PER_PAGE = 12
  MATCH_ALL = '*'

  attr_reader :query, :options

  def initialize(query: nil, options: {})
    @query = query.to_s.strip
    @options = options
  end

  def call
    scope = search_scope
    scope = scope.where(state_id: options[:state_id]) if options[:state_id].present?
    scope = scope.order(date: :desc) if options[:state_id].present?
    scope.page(options[:page]).per(PER_PAGE)
  end

  private

  def search_scope
    return Case.all if query.blank? || query == MATCH_ALL

    Case.search_text(query)
  end
end
