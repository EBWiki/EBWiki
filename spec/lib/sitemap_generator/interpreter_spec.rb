# frozen_string_literal: true

require 'rails_helper'

describe SitemapGenerator::Interpreter do
  describe '.run' do
    it 'does not raise an error' do
      allow(SitemapGenerator::Sitemap).to receive(:ping_search_engines).and_return true
      allow(SitemapGenerator::Sitemap).to receive(:create).and_yield

      # Create some test data here with FactoryGirl

      expect { described_class.run }.not_to raise_error
    end
  end
end
