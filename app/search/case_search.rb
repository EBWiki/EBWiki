# frozen_string_literal: true

# Functionality to dynamically search cases. Backed by pg_search's
# `search_text` scope on Case (Postgres full-text search over a generated
# tsvector column). Returns a Kaminari-paginated ActiveRecord::Relation,
# so callers can keep using `.total_count` and standard relation iteration.
class CaseSearch
  PER_PAGE = 12

  attr_reader :query, :options

  def initialize(query: nil, options: {})
    @query = query.to_s.strip.presence
    @options = options
  end

  def call
    filtered_scope.page(options[:page]).per(PER_PAGE)
  end

  private

  def filtered_scope
    scope = query ? Case.search_text(query) : Case.all
    scope = scope.where(state_id: options[:state_id]) if options[:state_id].present?
    scope = scope.order(date: :desc) if options[:state_id].present?
    scope
  end
end
