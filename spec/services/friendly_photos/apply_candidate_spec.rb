# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::ApplyCandidate do
  let(:this_case) { create(:case) }
  let(:candidate) { create(:photo_candidate, case: this_case) }

  it 'applies a reviewed Wikimedia portrait' do
    allow(this_case).to receive(:remote_avatar_url=)
    allow(this_case).to receive(:save).and_return(true)

    result = described_class.call(this_case: this_case, candidate: candidate)

    expect(result.success).to be true
    expect(this_case).to have_received(:remote_avatar_url=).with(candidate.image_url)
    expect(this_case.avatar_kind).to eq('portrait')
    expect(candidate.reload).to be_accepted
  end

  it 'refuses mugshot candidates' do
    candidate.update!(likely_mugshot: true, title: 'Booking photo')

    result = described_class.call(this_case: this_case, candidate: candidate)

    expect(result.success).to be false
    expect(result.error).to include('Mugshot')
    expect(candidate.reload).to be_pending
  end

  it 'refuses candidates from another case' do
    other_case = create(:case)
    result = described_class.call(this_case: other_case, candidate: candidate)

    expect(result.success).to be false
    expect(candidate.reload).to be_pending
  end
end
