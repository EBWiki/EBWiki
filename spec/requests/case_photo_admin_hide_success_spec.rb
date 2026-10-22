# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin case photo hide when status is shown', type: :request do
  let(:admin) { create(:admin) }
  let(:this_case) do
    create(:case).tap do |record|
      record.update!(
        photo_url: 'https://example.com/photos/victim.jpg',
        photo_status: :shown
      )
    end
  end

  before do
    sign_in admin
    post admin_case_photo_hide_path(this_case)
  end

  it 'hides the photo and reports success', versioning: true do
    expect(this_case.reload.photo_hidden?).to be(true)
    expect(response).to redirect_to(case_path(this_case))
    expect(flash[:notice]).to eq('Case photo hidden.')
    expect(CasePhotoAdminAuditLog.last.case_id).to eq(this_case.id)
    expect(this_case.versions.last.whodunnit).to eq(admin.id.to_s)
  end
end
