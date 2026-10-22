# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin case photo hide skip outcomes', type: :request do
  let(:admin) { create(:admin) }

  before { sign_in admin }

  it 'skips when already hidden', versioning: true do
    this_case = create(:case).tap do |record|
      record.update!(photo_url: 'https://example.com/photos/victim.jpg', photo_status: :hidden)
    end
    audit_before = CasePhotoAdminAuditLog.count
    versions_before = this_case.versions.count

    post admin_case_photo_hide_path(this_case)

    expect(CasePhotoAdminAuditLog.count).to eq(audit_before)
    expect(this_case.reload.versions.count).to eq(versions_before)
    expect(flash[:notice]).to eq('Case photo was already hidden.')
  end

  it 'skips when removed', versioning: true do
    this_case = create(:case).tap { |record| record.update!(photo_status: :removed) }
    audit_before = CasePhotoAdminAuditLog.count

    post admin_case_photo_hide_path(this_case)

    expect(CasePhotoAdminAuditLog.count).to eq(audit_before)
    expect(flash[:notice]).to eq('Case photo is marked removed; nothing was changed.')
  end

  it 'skips when unset', versioning: true do
    this_case = create(:case)
    audit_before = CasePhotoAdminAuditLog.count

    post admin_case_photo_hide_path(this_case)

    expect(CasePhotoAdminAuditLog.count).to eq(audit_before)
    expect(flash[:notice]).to eq('Case photo is not currently shown; nothing was changed.')
  end
end
