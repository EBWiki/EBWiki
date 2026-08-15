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
end
