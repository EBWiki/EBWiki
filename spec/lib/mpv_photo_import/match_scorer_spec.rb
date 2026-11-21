# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MpvPhotoImport::MatchScorer do
  def build_scorer(mpv_name:, mpv_date:, mpv_state:, case_title:, case_date:, case_state:)
    context = MpvPhotoImport::MatchContext.new(
      mpv_name: mpv_name,
      mpv_date: mpv_date,
      mpv_state_code: mpv_state,
      case_title: case_title,
      case_date: case_date,
      case_state_code: case_state
    )
    described_class.new(context)
  end

  it 'auto-accepts only when name, date, and state all match exactly' do
    scorer = build_scorer(
      mpv_name: 'Maria Lopez',
      mpv_date: Date.new(2020, 5, 15),
      mpv_state: 'CA',
      case_title: 'Maria Lopez',
      case_date: Date.new(2020, 5, 15),
      case_state: 'CA'
    )

    expect(scorer.auto_accept?).to be(true)
    expect(scorer.review?).to be(false)
  end

  it 'does not auto-accept when the name is only a near match' do
    scorer = build_scorer(
      mpv_name: 'Jon Smith',
      mpv_date: Date.new(2020, 6, 1),
      mpv_state: 'TX',
      case_title: 'John Smith',
      case_date: Date.new(2020, 6, 1),
      case_state: 'TX'
    )

    expect(scorer.auto_accept?).to be(false)
    expect(scorer.review?).to be(true)
  end

  it 'does not auto-accept when the date differs' do
    scorer = build_scorer(
      mpv_name: 'Alice Exact',
      mpv_date: Date.new(2020, 8, 10),
      mpv_state: 'OH',
      case_title: 'Alice Exact',
      case_date: Date.new(2020, 8, 11),
      case_state: 'OH'
    )

    expect(scorer.auto_accept?).to be(false)
    expect(scorer.review?).to be(true)
  end
end
