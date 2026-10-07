# frozen_string_literal: true

# Functionality to dynamically search cases
class CaseSearch
  PER_PAGE = 12

  attr_reader :query, :options

  def initialize(query: nil, options: {})
    @query = query.presence || '*'
    @options = options
  end

  def call
    relation = Case.all
    relation = apply_text_search(relation)
    relation = apply_state_filter(relation)
    relation = apply_order(relation)
    relation.page(options[:page]).per(PER_PAGE)
  end

  private

  def apply_text_search(relation)
    return relation if @query == '*'

    relation.search_text(@query)
  end

  def apply_state_filter(relation)
    return relation if options[:state_id].blank?

    relation.where(state_id: options[:state_id])
  end

  def apply_order(relation)
    relation.order(date: :desc)
  end
end
