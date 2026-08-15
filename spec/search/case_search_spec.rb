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
      summary: 'initial entry',
      date: 2.weeks.ago
    )
  end

  describe '#call' do
    it 'returns all cases when query is blank' do
      results = described_class.new(query: nil).call
      expect(results.total_count).to eq(2)
    end

    it 'treats whitespace-only queries as blank' do
      results = described_class.new(query: '   ').call
      expect(results.total_count).to eq(2)
    end

    it 'filters by free-text query against title' do
      results = described_class.new(query: 'shooting').call
      expect(results).to include(houston_case)
      expect(results).not_to include(baton_rouge_case)
    end

    it 'filters by free-text query against city' do
      results = described_class.new(query: 'Baton').call
      expect(results).to include(baton_rouge_case)
      expect(results).not_to include(houston_case)
    end

    it 'filters by state_id when provided' do
      results = described_class.new(query: nil, options: { state_id: texas.id }).call
      expect(results).to include(houston_case)
      expect(results).not_to include(baton_rouge_case)
    end

    it 'orders by date desc when state_id is provided' do
      newer_texas_case = FactoryBot.create(
        :case,
        title: 'Recent Houston incident',
        city: 'Houston',
        state: texas,
        date: 1.day.ago
      )
      older_texas_case = FactoryBot.create(
        :case,
        title: 'Old Houston incident',
        city: 'Houston',
        state: texas,
        date: 5.years.ago
      )
      results = described_class.new(query: nil, options: { state_id: texas.id }).call.to_a
      expect(results.first).to eq(newer_texas_case).or eq(houston_case)
      expect(results.last).to eq(older_texas_case)
    end

    it 'combines free-text query and state_id filter' do
      FactoryBot.create(:case, title: 'shooting in Dallas', city: 'Dallas', state: texas)
      results = described_class.new(query: 'shooting', options: { state_id: texas.id }).call
      expect(results.map(&:city)).to all(eq('Houston').or eq('Dallas'))
      expect(results).not_to include(baton_rouge_case)
    end

    it 'paginates results with PER_PAGE per page' do
      results = described_class.new(query: nil).call
      expect(results.limit_value).to eq(CaseSearch::PER_PAGE)
    end
  end
end
