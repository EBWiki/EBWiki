# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin case photo hide for non-admins', type: :request do
  let(:this_case) do
    create(:case).tap do |record|
      record.update!(photo_url: 'https://example.com/photos/victim.jpg', photo_status: :shown)
    end
  end
  let(:user) { create(:user) }

  before do
    sign_in user
    post admin_case_photo_hide_path(this_case)
  end

  it 'does not hide the photo' do
    expect(this_case.reload.photo_shown?).to be(true)
  end

  it 'redirects away from the admin action' do
    expect(response).to redirect_to(root_path)
  end
end
