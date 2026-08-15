# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::CurrentAvatarClassifier do
  it 'marks unclassified booking filenames as mugshots' do
    mugshot_case = create(:case)
    portrait_case = create(:case)
    mugshot_case.update_columns(avatar: 'uploads/case/avatar/1/booking_photo.jpg')
    portrait_case.update_columns(avatar: 'uploads/case/avatar/2/family_portrait.jpg')

    updated = described_class.call

    expect(updated).to eq(1)
    expect(mugshot_case.reload).to be_mugshot
    expect(portrait_case.reload).to be_unclassified
  end
end
