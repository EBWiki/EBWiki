# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoFinder::ContextMatcher do
  let(:state) { create(:state, name: 'New York') }
  let(:case_record) do
    kase = create(:case, city: 'Albany', state: state, date: Date.new(2019, 5, 1))
    create(:subject, case: kase, name: 'Jordan Rivera')
    kase.reload
  end

  def candidate(text)
    PhotoFinder::Candidate.new(
      image_url: 'https://example.com/photo.jpg',
      source_page_url: 'https://example.com/story',
      source_name: 'openverse',
      license_label: 'CC BY',
      license_url: nil,
      title: text,
      description: nil
    )
  end

  it 'requires the person name in source text' do
    expect(described_class.matches?(candidate('Jordan Rivera memorial in Albany 2019'), case_record)).to be(true)
    expect(described_class.matches?(candidate('Unrelated city festival'), case_record)).to be(false)
  end
end
