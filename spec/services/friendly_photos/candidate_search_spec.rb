# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::CandidateSearch do
  let(:this_case) { create(:case, city: 'North Charleston') }
  let!(:subject_record) { create(:subject, case: this_case, name: 'Walter Scott') }
  let(:portrait_hit) do
    FriendlyPhotos::WikimediaClient::Hit.new(
      source: 'wikimedia_commons',
      title: 'Walter Scott portrait',
      image_url: 'https://upload.wikimedia.org/wikipedia/commons/w/ws/portrait.jpg',
      page_url: 'https://commons.wikimedia.org/wiki/File:Walter_Scott_portrait.jpg',
      license: 'CC BY-SA 4.0',
      author: 'Family',
      description: 'Family photo of Walter Scott'
    )
  end
  let(:mugshot_hit) do
    FriendlyPhotos::WikimediaClient::Hit.new(
      source: 'wikimedia_commons',
      title: 'Walter Scott mugshot',
      image_url: 'https://upload.wikimedia.org/wikipedia/commons/w/ws/mugshot.jpg',
      page_url: 'https://commons.wikimedia.org/wiki/File:Walter_Scott_mugshot.jpg',
      license: 'Public domain',
      author: 'Sheriff',
      description: 'Booking photo'
    )
  end
  let(:client) { instance_double(FriendlyPhotos::WikimediaClient) }

  before do
    allow(client).to receive(:search).and_return([portrait_hit, mugshot_hit])
  end

  it 'persists friendly and flagged candidates without overwriting reviews' do
    records = described_class.new(client: client).call(this_case: this_case)

    expect(records.size).to eq(2)
    expect(this_case.photo_candidates.friendly.pending.size).to eq(1)
    expect(this_case.photo_candidates.where(likely_mugshot: true).size).to eq(1)

    accepted = this_case.photo_candidates.friendly.first
    accepted.accepted!
    described_class.new(client: client).call(this_case: this_case)
    expect(accepted.reload).to be_accepted
  end

  it 'uses the case title when a case has no subjects' do
    subject_record.destroy
    this_case.subjects.reload

    described_class.new(client: client).call(this_case: this_case)

    expect(client).to have_received(:search).with(query: this_case.title)
  end
end
