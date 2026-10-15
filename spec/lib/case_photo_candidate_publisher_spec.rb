# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasePhotoCandidatePublisher do
  let(:admin) { create(:admin) }
  let(:state) { create(:state, name: 'New York') }
  let(:case_record) do
    kase = create(:case, city: 'Albany', state: state, date: Date.new(2019, 5, 1))
    create(:subject, case: kase, name: 'Jordan Rivera')
    kase.reload
  end
  let(:allowed_image_url) do
    'https://api.openverse.org/v1/thumbs/610756ec-ae31-4d5e-8f03-8cc52f31b71d'
  end
  let(:candidate) do
    create(:case_photo_candidate, case: case_record, image_url: allowed_image_url)
  end

  before do
    png = File.binread(Rails.root.join('app/assets/images/default-user-icon.png'))
    stub_request(:get, candidate.image_url)
      .to_return(status: 200, body: png, headers: { 'Content-Type' => 'image/png' })
  end

  it 'approves a pending candidate and attaches the image to the case' do
    described_class.new(candidate, reviewer: admin).approve!

    expect(candidate.reload).to be_approved
    expect(candidate.reviewed_by).to eq(admin)
    expect(case_record.reload.avatar?).to be(true)
  end

  it 'does not download disallowed image hosts on approve' do
    candidate.update!(image_url: 'https://evil.example/photo.jpg')

    expect do
      described_class.new(candidate, reviewer: admin).approve!
    end.to raise_error(CasePhotoCandidatePublisher::Error, /allowed Wikimedia Commons or Openverse/)

    expect(candidate.reload).to be_pending
    expect(case_record.reload.avatar?).to be(false)
    expect(a_request(:get, 'https://evil.example/photo.jpg')).not_to have_been_made
  end

  it 'rejects a pending candidate without changing the case avatar' do
    described_class.new(candidate, reviewer: admin).reject!(reason: 'Wrong person')

    expect(candidate.reload).to be_rejected
    expect(candidate.rejection_reason).to eq('Wrong person')
    expect(case_record.reload.avatar?).to be(false)
  end
end
