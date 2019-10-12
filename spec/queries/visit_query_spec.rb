# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VisitQuery do
  describe '#sorted_by_hits' do
    subject(:sorted_by_hits) { described_class.new.sorted_by_hits(limit: 2) }

    it 'returns the number of visits sorted by landing page' do
      create_list(:visit, 2, landing_page: 'https://ebwiki.org/about')
      create_list(:visit, 2)
      visit = FactoryBot.create(:visit, landing_page: 'https://ebwiki.org/analytics')

      expect(sorted_by_hits.count).to eq(2)
      expect(sorted_by_hits.to_a).not_to include [visit.landing_page, 1]
    end
  end
end
