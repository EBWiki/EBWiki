# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoFinderJob do
  let(:state) { create(:state, name: 'New York') }
  let(:case_record) do
    kase = create(:case, city: 'Albany', state: state, date: Date.new(2019, 5, 1))
    create(:subject, case: kase, name: 'Jordan Rivera')
    kase.reload
  end

  let(:finder_candidate) do
    PhotoFinder::Candidate.new(
      image_url: 'https://news.example/rivera.jpg',
      source_page_url: 'https://news.example/story',
      source_name: 'wikimedia_commons',
      license_label: 'CC BY-SA 4.0',
      license_url: 'https://creativecommons.org/licenses/by-sa/4.0/',
      title: 'Jordan Rivera memorial in Albany 2019',
      description: 'Community vigil'
    )
  end

  it 'stores pending candidates for cases without photos' do
    search = instance_double(PhotoFinder::Search, call: [finder_candidate])
    allow(PhotoFinder::Search).to receive(:new).with(case_record).and_return(search)

    expect do
      described_class.perform_now(case_record.id)
    end.to change(CasePhotoCandidate, :count).by(1)

    candidate = CasePhotoCandidate.last
    expect(candidate).to be_pending
    expect(candidate.license_label).to eq('CC BY-SA 4.0')
    expect(candidate.source_name).to eq('wikimedia_commons')
  end

  it 'skips cases that already have an avatar' do
    case_record.avatar = File.open(Rails.root.join('app/assets/images/default-user-icon.png'))
    case_record.save!

    expect(PhotoFinder::Search).not_to receive(:new)

    described_class.perform_now(case_record.id)
  end
end
