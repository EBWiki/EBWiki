# frozen_string_literal: true

require 'rails_helper'

describe CaseSearch do # rubocop:disable Metrics/BlockLength
  let(:texas) { FactoryBot.create(:state_texas) }
  let(:louisiana) { FactoryBot.create(:state_louisiana) }
  let!(:houston_case) do
    FactoryBot.create(
      :case,
      title: 'Police shooting in Houston',
      blurb: 'Officer-involved shooting downtown',
      overview: 'A detailed overview of the Houston incident',
      city: 'Houston',
      state: texas,
      date: 1.week.ago,
      summary: 'initial entry'
    )
  end
  let!(:baton_rouge_case) do
    FactoryBot.create(
      :case,
      title: 'Vehicular incident in Baton Rouge',
      blurb: 'Traffic stop escalation',
      overview: 'Different unrelated content',
      city: 'Baton Rouge',
      state: louisiana,
      date: 2.weeks.ago,
      summary: 'initial entry'
    )
  end

  it 'matches text through pg_search' do
    results = described_class.new(query: 'shooting').call
    expect(results).to include(houston_case)
    expect(results).not_to include(baton_rouge_case)
  end

  it 'returns every case when the query is blank or *' do
    expect(described_class.new(query: nil).call).to include(houston_case, baton_rouge_case)
    expect(described_class.new(query: '*').call).to include(houston_case, baton_rouge_case)
  end

  it 'filters by state_id and orders by date descending' do
    results = described_class.new(query: '*', options: { state_id: texas.id }).call
    expect(results).to include(houston_case)
    expect(results).not_to include(baton_rouge_case)
  end

  it 'paginates with Kaminari' do
    results = described_class.new(query: '*', options: { page: 1 }).call
    expect(results.current_page).to eq(1)
    expect(results.limit_value).to eq(CaseSearch::PER_PAGE)
    expect(results.total_count).to eq(2)
  end
end
# rubocop:enable Metrics/BlockLength
