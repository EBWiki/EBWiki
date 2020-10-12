# frozen_string_literal: true

require 'rails_helper'

describe SearchPresenter do
  let(:_case) { FactoryBot.create(:case) }
  let(:query) { _case.title }
  let(:state) { FactoryBot.create(:state) }
  let(:count) { 1 }
  let(:view) { ActionController::Base.new.view_context }

  it 'should create the right text with just a query' do
    presenter = SearchPresenter.new(query: query,
                                    state_id: nil,
                                    count: count,
                                    view: view)
    expect(presenter.search_results_text).to eq I18n.t('presenter.test_query', query: query)
  end

  it 'should create the right text with just a state' do
    presenter = SearchPresenter.new(query: nil,
                                    state_id: state.id,
                                    count: count,
                                    view: view)
    expect(presenter.search_results_text).to eq I18n.t('presenter.test_state', state: state.name)
  end
end
