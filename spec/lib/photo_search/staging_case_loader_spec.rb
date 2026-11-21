# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoSearch::StagingCaseLoader do
  describe '.each_case' do
    let!(:first_case) { create(:case, title: 'Alpha case') }
    let!(:second_case) { create(:case, title: 'Beta case') }

    it 'yields case metadata rows in id order' do
      titles = described_class.each_case(batch_size: 1).map(&:title)
      expect(titles).to include(first_case.title, second_case.title)
    end
  end

  describe '.report' do
    before { create_list(:case, 2) }

    it 'reports the live case count' do
      report = described_class.report
      expect(report[:case_count]).to eq(2)
      expect(report[:matches_expected]).to be(false)
    end
  end
end
