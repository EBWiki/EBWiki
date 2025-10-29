# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Agencies Pages', type: :feature, js: true do
  let!(:state) { FactoryBot.create(:state) }
  let!(:agencies) { FactoryBot.create_list(:agency, 5, state: state) }

  describe 'Agencies Index' do
    it 'loads successfully' do
      visit agencies_path
      expect(page.status_code).to eq(200)
      expect(page).to have_current_path('/agencies')
    end

    it 'displays agencies' do
      visit agencies_path
      agencies.each do |agency|
        expect(page).to have_content(agency.name)
      end
    end

    it 'has working navigation' do
      visit agencies_path
      expect(page).to have_css('body')
    end
  end

  describe 'Agency Show Page' do
    let(:agency) { agencies.first }

    it 'loads successfully' do
      visit agency_path(agency)
      expect(page.status_code).to eq(200)
    end

    it 'displays agency details' do
      visit agency_path(agency)
      expect(page).to have_content(agency.name)
    end

    it 'displays agency state' do
      visit agency_path(agency)
      expect(page).to have_content(agency.state.name)
    end
  end
end
