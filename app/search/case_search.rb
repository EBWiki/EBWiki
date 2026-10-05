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
    constraints = {
      page: options[:page],
      per_page: PER_PAGE
    }

    constraints[:where] = where
    constraints[:order] = order

    Case.search(query, constraints)
  end

  def where
    if options[:state_id].present?
      { state_id: options[:state_id] }
    else
      {}
    end
  end

  def order
    if options[:state_id].present?
      { date: :desc }
    else
      {}
    end
  end
end
