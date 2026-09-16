# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::BatchSearch do
  let(:this_case) { create(:case) }

  before { create(:subject, case: this_case, name: 'Walter Scott') }

  it 'searches cases that need a friendly photo' do
    candidate = create(:photo_candidate, case: this_case)
    allow(FriendlyPhotos::CandidateSearch).to receive(:call).and_return(
      FriendlyPhotos::CandidateSearch::Result.new(
        records: [candidate],
        planner_ai_used: true,
        vision_ai_used_count: 1,
        vision_failed_count: 0,
        warnings: []
      )
    )

    results = described_class.call(scope: Case.where(id: this_case.id))

    expect(results.first[:slug]).to eq(this_case.slug)
    expect(results.first[:subject_name]).to eq('Walter Scott')
    expect(results.first[:candidates].first[:image_url]).to eq(candidate.image_url)
  end
end
