# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin case photo hide rollback', type: :request do
  let(:admin) { create(:admin) }
  let(:this_case) do
    create(:case).tap do |record|
      record.update!(photo_url: 'https://example.com/photos/victim.jpg', photo_status: :shown)
    end
  end

  before do
    sign_in admin
    allow(CasePhotoAdminAuditLog).to receive(:record_hide!).and_raise(ActiveRecord::RecordInvalid)
    post admin_case_photo_hide_path(this_case)
  end

  it 'rolls back the status change' do
    expect(this_case.reload.photo_shown?).to be(true)
    expect(response).to redirect_to(admin_cases_path)
  end
end
