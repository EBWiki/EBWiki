# frozen_string_literal: true

# Site header search over cases via Postgres full-text search.
class CaseSearch
  PER_PAGE = 12
  MATCH_ALL = '*'

  attr_reader :query, :options

  def initialize(query: nil, options: {})
    @query = query.presence || MATCH_ALL
    @options = options
  end

  def call
    paginate(ordered(filtered(results)))
  end

  private

  def results
    match_all? ? Case.all : Case.search_text(query)
  end

  def match_all?
    query == MATCH_ALL
  end

  def filtered(scope)
    return scope if options[:state_id].blank?

    scope.where(state_id: options[:state_id])
  end

  def ordered(scope)
    return scope if options[:state_id].blank?

    scope.order(date: :desc)
  end

  def paginate(scope)
    scope.page(options[:page]).per(PER_PAGE)
  end
end
