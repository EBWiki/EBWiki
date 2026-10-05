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
  let!(:older_shooting_case) do
    FactoryBot.create(
      :case,
      title: 'Archive shooting in Houston suburbs',
      blurb: 'Historical shooting records',
      overview: 'Older Houston-area shooting',
      city: 'Houston',
      state: texas,
      date: 3.months.ago,
      summary: 'archived entry'
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
    expect(results.total_count).to eq(3)
  end

  it 'orders blank-query results by date descending' do
    results = described_class.new(query: nil).call
    expect(results.to_a).to eq([baton_rouge_case, houston_case, older_shooting_case])
  end

  it 'orders nonblank search results by date descending, not pg_search rank' do
    results = described_class.new(query: 'shooting').call.to_a
    shooting_cases = [houston_case, older_shooting_case]
    expect(results).to match([houston_case, older_shooting_case])
    expect(results & shooting_cases).to eq([houston_case, older_shooting_case])
  end

  describe 'pg_search parity (fixture queries)' do
    let(:new_york) { FactoryBot.create(:state_ny) }
    let!(:tamir_case) do
      FactoryBot.create(
        :case,
        title: 'Tamir Rice playground shooting',
        blurb: 'Buffalo park incident',
        overview: 'Involved Buffalo Division of Police patrol officers',
        city: 'Buffalo',
        state: new_york,
        date: 2.weeks.ago,
        summary: 'tamir case summary'
      )
    end
    let!(:dallas_case) do
      FactoryBot.create(
        :case,
        title: 'Traffic stop in Dallas',
        blurb: 'Dallas Police Department response',
        overview: 'Dallas metro area',
        city: 'Dallas',
        state: texas,
        date: 5.days.ago,
        summary: 'dallas case summary'
      )
    end

    # Query, optional search options, category label, expected case title (PR parity table).
    PARITY_ROWS = [
      ['Houston', {}, 'city', 'Police shooting in Houston'],
      ['Tamir', {}, 'name', 'Tamir Rice playground shooting'],
      ['Buffalo Division', {}, 'agency', 'Tamir Rice playground shooting'],
      ['traffic', { state_id: :louisiana }, 'state', 'Vehicular incident in Baton Rouge'],
      ['Baton Rouge', {}, 'city', 'Vehicular incident in Baton Rouge'],
      ['escalation', {}, 'blurb', 'Vehicular incident in Baton Rouge'],
      ['detailed overview', {}, 'overview', 'Police shooting in Houston'],
      ['tamir case summary', {}, 'summary', 'Tamir Rice playground shooting'],
      ['shoot', {}, 'prefix', 'Police shooting in Houston'],
      ['Dallas Police', {}, 'agency', 'Traffic stop in Dallas']
    ].freeze

    PARITY_ROWS.each do |query, option_keys, category, expected_title|
      it "returns the expected case for #{category} query #{query.inspect}" do
        options = option_keys.transform_values do |value|
          value == :louisiana ? louisiana.id : value
        end
        results = described_class.new(query: query, options: options).call
        expect(results.map(&:title)).to include(expected_title),
                                       "parity miss for #{category} query #{query.inspect}"
      end
    end
  end
end
