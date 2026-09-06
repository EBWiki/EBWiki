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
  let(:homonym_hit) do
    FriendlyPhotos::WikimediaClient::Hit.new(
      source: 'wikimedia_commons',
      title: 'Sir Walter Scott',
      image_url: 'https://upload.wikimedia.org/wikipedia/commons/w/ws/sir-walter.jpg',
      page_url: 'https://commons.wikimedia.org/wiki/File:Sir_Walter_Scott.jpg',
      license: 'Public domain',
      author: 'Unknown',
      description: 'Portrait of the novelist Sir Walter Scott, 19th century'
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
          'Killing of Walter Scott',
          'Shooting of Walter Scott',
          'Walter Scott',
          'Walter Scott Albany',
          'Walter Scott portrait'
        ],
        ai_used: true
      )
    )
  end

  before do
    allow(client).to receive(:search).and_return([portrait_hit, mugshot_hit, homonym_hit])
    allow(FriendlyPhotos::VisionClassifier).to receive(:call).and_return(
      FriendlyPhotos::VisionClassifier::Result.new(
        likely_mugshot: false,
        reasons: ['vision ok'],
        score: 2,
        ai_used: true,
        failed: false
      )
    )
  end

  def search
    described_class.new(client: client, openverse: openverse, planner: planner).call(this_case: this_case)
  end

  it 'returns a result with AI usage counts' do
    result = search

    expect(result).to be_a(described_class::Result)
    expect(result.planner_ai_used).to be true
    expect(result.vision_ai_used_count).to eq(3)
    expect(result.records.size).to eq(3)
  end

  it 'persists planner and vision AI flags on candidates' do
    search

    candidate = this_case.photo_candidates.find_by(title: 'Walter Scott portrait')
    expect(candidate.planner_ai_used).to be true
    expect(candidate.vision_ai_used).to be true
  end

  it 'persists friendly and flagged candidates without overwriting reviews' do
    records = search.records

    expect(records.size).to eq(3)
    expect(this_case.photo_candidates.where(likely_mugshot: true).size).to eq(1)
    expect(this_case.photo_candidates.find_by(title: 'Sir Walter Scott')).to be_likely_homonym

    accepted = this_case.photo_candidates.find_by(title: 'Walter Scott portrait')
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

  it 'ranks portraits above homonyms and mugshots' do
    search
    ranked = this_case.photo_candidates.ranked

    expect(ranked.first.title).to eq('Walter Scott portrait')
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
      year: this_case.date&.year,
      slug: this_case.slug
    )
  end

  it 'plans killing-of and shooting-of queries for the subject' do
    name = subject_record.name
    search

    expect(planner).to have_received(:call).with(
      name: name,
      city: this_case.city,
      year: this_case.date&.year,
      slug: this_case.slug
    )
    expect(client).to have_received(:search).with(query: "Killing of #{name}", limit: 5)
    expect(client).to have_received(:search).with(query: "Shooting of #{name}", limit: 5)
  end
end
