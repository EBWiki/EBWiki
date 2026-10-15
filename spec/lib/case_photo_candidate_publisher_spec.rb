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
  let(:candidate) do
    create(:case_photo_candidate, case: case_record, image_url: 'https://news.example/rivera.jpg')
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

  it 'rejects a pending candidate without changing the case avatar' do
    described_class.new(candidate, reviewer: admin).reject!(reason: 'Wrong person')

    expect(candidate.reload).to be_rejected
    expect(candidate.rejection_reason).to eq('Wrong person')
    expect(case_record.reload.avatar?).to be(false)
  end
end
