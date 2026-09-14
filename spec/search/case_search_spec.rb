# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CaseSearch do
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
      date: 1.day.ago,
      summary: 'initial entry'
    )
  end

  it 'matches cases by full-text query' do
    results = described_class.new(query: 'shooting').call
    expect(results).to include(houston_case)
    expect(results).not_to include(baton_rouge_case)
  end

  it 'filters by state_id' do
    results = described_class.new(query: nil, options: { state_id: louisiana.id }).call
    expect(results).to include(baton_rouge_case)
    expect(results).not_to include(houston_case)
  end

  it 'treats a blank or * query as match-all' do
    results = described_class.new(query: '*').call
    expect(results).to include(houston_case, baton_rouge_case)
  end

  it 'paginates with Kaminari' do
    results = described_class.new(query: nil).call
    expect(results.current_page).to eq(1)
    expect(results.limit_value).to eq(described_class::PER_PAGE)
    expect(results.total_count).to eq(2)
  end

  it 'orders results by date descending' do
    results = described_class.new(query: nil).call
    expect(results.to_a).to eq([baton_rouge_case, houston_case])
  end
end
