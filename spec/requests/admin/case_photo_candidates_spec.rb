# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin case photo candidate review' do
  let(:admin) { create(:admin) }
  let(:candidate) { create(:case_photo_candidate) }

  before do
    sign_in admin
    png = File.binread(Rails.root.join('app/assets/images/default-user-icon.png'))
    stub_request(:get, candidate.image_url)
      .to_return(status: 200, body: png, headers: { 'Content-Type' => 'image/png' })
  end

  it 'lists pending candidates' do
    get admin_case_photo_candidates_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Case Photo Candidates')
  end

  it 'approves a candidate' do
    post approve_admin_case_photo_candidate_path(candidate)

    expect(response).to redirect_to(admin_case_photo_candidate_path(candidate))
    expect(candidate.reload).to be_approved
  end

  it 'rejects a candidate' do
    post reject_admin_case_photo_candidate_path(candidate), params: { rejection_reason: 'Not a match' }

    expect(response).to redirect_to(admin_case_photo_candidates_path)
    expect(candidate.reload).to be_rejected
  end
end
