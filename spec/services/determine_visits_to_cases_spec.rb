# frozen_string_literal: true

require 'rails_helper'

describe DetermineVisitsToCases do
  it 'returns visits to cases' do
    this_case = FactoryBot.create(:case)
    slug_name = this_case.friendly_id
    case_url = 'https://ebwiki.org/cases/' + slug_name
    visit_info = [['https://ebwiki.org/', 1],
                  [case_url, 3]]
    cases = DetermineVisitsToCases.call(visit_info)
    expect(cases).to eq([[this_case, 3]])
  end
end
