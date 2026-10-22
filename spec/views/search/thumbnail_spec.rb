# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'search/_thumbnail' do
  let(:this_case) do
    CasePhotoTestData.attach_test_avatar(create(:case)).tap do |record|
      record.update!(
        photo_status: :hidden,
        photo_url: 'https://example.com/photos/victim.jpg'
      )
    end
  end

  before do
    render partial: 'search/thumbnail', locals: { this_case: this_case }
  end

  it 'shows the name card and not image urls' do
    expect(rendered).to include('case-photo-name-card--thumbnail')
    expect(rendered).not_to include('https://example.com/photos/victim.jpg')
    expect(rendered).not_to include(this_case.avatar.large_avatar.url)
  end
end
