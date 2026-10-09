# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Friendly photos batch search sample set (GKT-1101)' do
  let(:scope) { Case.where(id: seeded_cases.map(&:id)).order(:slug) }

  before do
    Geocoder.configure(lookup: :test)
    Geocoder::Lookup::Test.set_default_stub(
      [{ 'latitude' => 42.6525793, 'longitude' => -73.7562317 }]
    )
    seeded_cases
  end

  around do |example|
    ENV['FRIENDLY_PHOTOS_STUB_AI'] = '1'
    WebMock.disable_net_connect!(allow_localhost: true)
    FriendlyPhotosSampleSet.install_webmock!
    example.run
  ensure
    ENV.delete('FRIENDLY_PHOTOS_STUB_AI')
    WebMock.reset!
    FriendlyPhotosSampleSet.reset!
  end

  def seeded_cases
    @seeded_cases ||= FriendlyPhotosSampleSet.seed!
  end

  def batch_rows
    FriendlyPhotos::BatchSearch.call(scope: scope)
  end

  it 'runs batch search over ten seeded cases using recorded HTTP responses only' do
    rows = batch_rows

    expect(rows.size).to eq(10)
    FriendlyPhotosSampleSet.cases.each do |manifest_row|
      row = rows.find { |entry| entry[:slug] == manifest_row.fetch('slug') }
      expect(row).to be_present, "missing batch row for #{manifest_row.fetch('slug')}"

      this_case = Case.find(row[:case_id])
      candidates = this_case.photo_candidates.reload.to_a
      expect(FriendlyPhotosSampleSet.expectation_met?(manifest_row, candidates)).to be(true),
                                                                                    outcome_debug(
                                                                                      manifest_row, candidates
                                                                                    )

      candidates.select(&:likely_mugshot?).each do |mugshot|
        result = FriendlyPhotos::ApplyCandidate.call(this_case: this_case, candidate: mugshot)
        expect(result.success).to be(false)
        expect(result.error).to include('healthy profile picture')
        expect(mugshot.reload).to be_pending
      end
    end

    expect(a_request(:get, /commons\.wikimedia\.org/)).to have_been_made.at_least_once
    expect(a_request(:get, /api\.openverse\.org/)).to have_been_made.at_least_once
  end

  describe 'photos:search_friendly' do
    include_context 'rake'

    let(:task_name) { 'photos:search_friendly' }

    it 'prints JSON for the ten seeded cases' do
      ENV['LIMIT'] = '10'
      ENV['FORMAT'] = 'json'

      expect { subject.invoke }.to output(/gkt1101-sample-alpha/).to_stdout
    ensure
      ENV.delete('LIMIT')
      ENV.delete('FORMAT')
      subject.reenable
    end
  end

  def outcome_debug(manifest_row, candidates)
    friendly = candidates.count { |candidate| !candidate.likely_mugshot? }
    "slug=#{manifest_row.fetch('slug')} expected=#{manifest_row.fetch('expectation')} " \
      "stored=#{candidates.size} friendly=#{friendly} " \
      "message=#{FriendlyPhotosSampleSet.none_found_message(candidates).inspect}"
  end
end
