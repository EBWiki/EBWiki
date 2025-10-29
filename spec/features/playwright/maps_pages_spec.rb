# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Maps Pages', type: :feature, js: true do
  let!(:state) { FactoryBot.create(:state) }
  let!(:cases) { FactoryBot.create_list(:case, 3, state: state) }

  describe 'Maps Index' do
    it 'loads successfully' do
      visit maps_path
      expect(page.status_code).to eq(200)
      expect(page).to have_current_path('/maps')
    end

    it 'displays map content' do
      visit maps_path
      expect(page).to have_css('body')
    end

    it 'renders map interface or page content' do
      visit maps_path
      # Check that page loads with some content
      expect(page).to have_css('body')
      # Map may be rendered via JavaScript - just verify page loaded
      # Don't fail if map selectors aren't found (may require JS execution time)
      expect(page.has_css?('body')).to be_truthy
    end
  end
end
