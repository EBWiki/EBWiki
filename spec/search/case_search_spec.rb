# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CaseSearch do
  let(:texas) { create(:state_texas) }
  let(:louisiana) { create(:state_louisiana) }
  let!(:houston_case) do
    create(
      :case,
      title: 'Police shooting in Houston',
      city: 'Houston',
      state: texas,
      date: Date.new(2020, 5, 1)
    )
  end
  let!(:baton_rouge_case) do
    create(
      :case,
      title: 'Vehicular incident in Baton Rouge',
      city: 'Baton Rouge',
      state: louisiana,
      date: Date.new(2021, 6, 1)
    )
  end

  it 'finds cases by full-text query instead of Searchkick' do
    results = described_class.new(query: 'Houston').call

    expect(results).to include(houston_case)
    expect(results).not_to include(baton_rouge_case)
    expect(results.total_count).to eq(1)
  end

  it 'returns every case when the query is blank' do
    results = described_class.new(query: nil).call

    expect(results).to include(houston_case, baton_rouge_case)
  end

  it 'filters and date-sorts when a state is selected' do
    results = described_class.new(query: '*', options: { state_id: louisiana.id }).call

    expect(results).to contain_exactly(baton_rouge_case)
    expect(results.to_a).to eq([baton_rouge_case])
  end
end
