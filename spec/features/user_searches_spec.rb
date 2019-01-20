# frozen_string_literal: true

require 'rails_helper'

feature 'User searches for case' do
  let(:this_case) { FactoryBot.create(:case) }

  scenario 'User searches for case with at least one match found', versioning: true do
    VCR.use_cassette 'basic_search' do
      visit root_path
      fill_in 'query', with: this_case.city
      click_button 'Search'
      expect(page).to have_text('Displaying cases')
    end
  end
end