# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin case photo hide for admins', type: :request do
  let(:this_case) do
    create(:case).tap do |record|
      record.update!(
        photo_url: 'https://example.com/photos/victim.jpg',
        photo_status: :shown
      )
    end
  end
  let(:admin) { create(:admin) }

  before do
    sign_in admin
    post admin_case_photo_hide_path(this_case)
  end

  it 'returns redirect' do
    expect(response).to redirect_to(case_path(this_case))
  end

  it 'hides the photo status without removing the url' do
    this_case.reload
    expect(this_case.photo_hidden?).to be(true)
    expect(this_case.photo_url).to eq('https://example.com/photos/victim.jpg')
  end

  it 'shows the neutral name card on the next case page load' do
    follow_redirect!
    expect(response.body).to include('case-photo-name-card')
    expect(response.body).to include(this_case.title)
    expect(response.body).not_to include('https://example.com/photos/victim.jpg')
  end

  it 'writes an audit log with only case id, action, and time' do
    log = CasePhotoAdminAuditLog.last
    expect(log.case_id).to eq(this_case.id)
    expect(log.action).to eq('hide')
    expect(log.created_at).to be_present
    expect(log.attributes.keys).to match_array(%w[id case_id action created_at])
  end
end

RSpec.describe 'Admin case photo hide for non-admins', type: :request do
  let(:this_case) do
    create(:case).tap do |record|
      record.update!(
        photo_url: 'https://example.com/photos/victim.jpg',
        photo_status: :shown
      )
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
