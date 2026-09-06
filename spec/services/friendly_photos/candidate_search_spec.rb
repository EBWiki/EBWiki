# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendlyPhotos::CandidateSearch do
  let(:this_case) { create(:case, city: 'Albany') }
  let!(:subject_record) { create(:subject, case: this_case, name: 'Walter Scott') }
  let(:portrait_hit) do
    FriendlyPhotos::WikimediaClient::Hit.new(
      source: 'wikimedia_commons',
      title: 'Walter Scott portrait',
      image_url: 'https://upload.wikimedia.org/wikipedia/commons/w/ws/portrait.jpg',
      page_url: 'https://commons.wikimedia.org/wiki/File:Walter_Scott_portrait.jpg',
      license: 'CC BY-SA 4.0',
      license_url: 'https://creativecommons.org/licenses/by-sa/4.0/',
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
  let(:farm_hit) do
    FriendlyPhotos::WikimediaClient::Hit.new(
      source: 'openverse',
      title: 'Walter Scott portrait',
      image_url: 'https://mugshots.com/walter.jpg',
      page_url: 'https://mugshots.com/walter',
      license: 'Unknown',
      author: 'Sheriff',
      description: 'Inmate lookup'
    )
  end
  let(:client) { instance_double(FriendlyPhotos::WikimediaClient) }
  let(:openverse) { instance_double(FriendlyPhotos::OpenverseClient, search: []) }
  let(:planner) do
    instance_double(
      FriendlyPhotos::SearchPlanner,
      call: FriendlyPhotos::SearchPlanner::Result.new(
        queries: [
          'Walter Scott',
          'Walter Scott Albany',
          'Walter Scott portrait',
          'Killing of Walter Scott',
          'Shooting of Walter Scott'
        ],
        ai_used: false
      )
    )
  end

  before do
    allow(client).to receive(:search).and_return([portrait_hit, mugshot_hit])
  end

  def search
    described_class.new(client: client, openverse: openverse, planner: planner).call(this_case: this_case)
  end

  it 'persists friendly and flagged candidates without overwriting reviews' do
    records = search

    expect(records.size).to eq(2)
    expect(this_case.photo_candidates.friendly.pending.size).to eq(1)
    expect(this_case.photo_candidates.where(likely_mugshot: true).size).to eq(1)
    expect(this_case.photo_candidates.friendly.first.license_url).to include('creativecommons.org')

    accepted = this_case.photo_candidates.friendly.first
    accepted.accepted!
    search
    expect(accepted.reload).to be_accepted
  end

  it 'excludes mugshot-farm hosts instead of storing them' do
    allow(openverse).to receive(:search).and_return([farm_hit])

    search

    urls = this_case.photo_candidates.pluck(:image_url)
    expect(urls).not_to include('https://mugshots.com/walter.jpg')
  end

  it 'ranks portraits above news stills and mugshots' do
    search
    ranked = this_case.photo_candidates.ranked

    expect(ranked.first).to be_friendly
    expect(ranked.first.score).to be > ranked.last.score
    expect(ranked.last).to be_likely_mugshot
  end

  it 'uses the case title when a case has no subjects' do
    subject_record.destroy
    this_case.subjects.reload
    allow(planner).to receive(:call).and_return(
      FriendlyPhotos::SearchPlanner::Result.new(queries: [this_case.title], ai_used: false)
    )

    search

    expect(planner).to have_received(:call).with(
      name: this_case.title,
      city: this_case.city,
      year: this_case.date&.year
    )
  end

  it 'plans killing-of and shooting-of queries for the subject' do
    name = subject_record.name
    search

    expect(planner).to have_received(:call).with(name: name, city: this_case.city, year: this_case.date&.year)
    expect(client).to have_received(:search).with(query: "Killing of #{name}")
    expect(client).to have_received(:search).with(query: "Shooting of #{name}")
    expect(client).to have_received(:search).with(query: "#{name} Albany")
  end
end
