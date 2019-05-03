# frozen_string_literal: true

# Presenter for search results page
class SearchPresenter
  def initialize(query:, state_id:, count:, view:)
    @query = query
    @count = count
    @view = view

    @state = state_id.present? ? State.where(id: state_id).pluck(:name).first : nil
  end

  def search_results_text
    if @query.present?
      "Your search for \"#{@query}\" #{state_text} has returned #{h.pluralize(@count, 'result')}."
    else
      "Your search for cases #{state_text} has returned #{h.pluralize(@count, 'result')}."
    end
  end

  def state_text
    @state.present? ? "in #{@state}" : ''
  end

  def h
    @view
  end
end
