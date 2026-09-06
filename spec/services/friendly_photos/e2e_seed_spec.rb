# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::E2eSeed do
  it 'creates a login, cases, and mixed photo candidates' do
    result = described_class.call

    expect(User.find_by(email: described_class::EMAIL)).to be_present
    expect(result[:missing].subjects.first.name).to eq('Jordan Doe')
    expect(result[:missing].photo_candidates.friendly.pending.size).to eq(1)
    expect(result[:missing].photo_candidates.where(likely_mugshot: true).size).to eq(1)
    expect(result[:portrait]).to be_portrait
    expect(Case.needing_friendly_photo).to include(result[:missing], result[:mugshot])
    expect(Case.needing_friendly_photo).not_to include(result[:portrait])
  end

  it 'reloads associations so a second seed still exposes subjects' do
    described_class.call
    result = described_class.call

    expect(result[:missing].subjects.map(&:name)).to eq(['Jordan Doe'])
    expect(result[:mugshot].subjects.map(&:name)).to eq(['Riley Mugshot'])
  end

  it 'removes prior seed rows with delete_all instead of destroy callbacks' do
    e2e_case = create(:case, slug: 'e2e-missing-photo')
    create(:photo_candidate, case: e2e_case)

    expect_any_instance_of(Case).not_to receive(:destroy)

    described_class.call
  end

  describe 'substantial review databases' do
    it 'upserts e2e fixtures without deleting unrelated or seed cases' do
      unrelated = create(:case, slug: 'real-case-from-dump', title: 'Real Case')
      e2e_case = create(:case, slug: 'e2e-missing-photo', title: 'Old E2E')
      create(:photo_candidate, case: e2e_case)

      allow(Case).to receive(:count).and_return(described_class::SUBSTANTIAL_CASE_THRESHOLD + 1)

      result = described_class.call

      expect(Case.exists?(unrelated.id)).to be(true)
      expect(Case.exists?(e2e_case.id)).to be(true)
      expect(result[:missing].title).to eq('E2E Missing Photo')
      expect(result[:missing].photo_candidates.count).to eq(2)
    end
  end
end
