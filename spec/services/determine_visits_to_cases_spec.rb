require 'rails_helper'

describe DetermineVisitsToCases do

  it 'returns visits to cases' do
    this_case = FactoryBot.create(:case)
    slug_name = this_case.friendly_id
    case_URL = 'https://ebwiki.org/cases/' + slug_name
    visit_info = [['https://ebwiki.org/', 1],
                  [case_URL, 3]]
    cases = DetermineVisitsToCases.call(visit_info)
    expect(cases).to eq([[cases, 3]])
  end
end