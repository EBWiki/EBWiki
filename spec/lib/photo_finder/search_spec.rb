# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoFinder::Search do
  let(:state) { create(:state, name: 'New York') }
  let(:case_record) do
    kase = create(:case, city: 'Albany', state: state, date: Date.new(2019, 5, 1))
    create(:subject, case: kase, name: 'Jordan Rivera')
    kase.reload
  end

  let(:good_candidate) do
    PhotoFinder::Candidate.new(
      image_url: 'https://news.example/rivera.jpg',
      source_page_url: 'https://news.example/story',
      source_name: 'openverse',
      license_label: 'CC BY 4.0',
      license_url: 'https://creativecommons.org/licenses/by/4.0/',
      title: 'Jordan Rivera memorial in Albany 2019',
      description: 'Community vigil'
    )
  end

  let(:mugshot_candidate) do
    PhotoFinder::Candidate.new(
      image_url: 'https://mugshots.example/booking.jpg',
      source_page_url: 'https://mugshots.example/booking',
      source_name: 'openverse',
      license_label: nil,
      license_url: nil,
      title: 'Jordan Rivera booking photo',
      description: nil
    )
  end

  let(:stub_client) do
    Class.new do
      def initialize(rows) = @rows = rows
      def search(_query, case_record: nil) = @rows
    end.new([good_candidate, mugshot_candidate])
  end

  it 'returns matched non-mugshot candidates' do
    results = described_class.new(case_record, clients: [stub_client]).call

    expect(results).to eq([good_candidate])
  end
end
