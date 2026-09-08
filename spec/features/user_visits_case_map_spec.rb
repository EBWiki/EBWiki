# frozen_string_literal: true

require 'rails_helper'

feature 'User visits case map' do
  let!(:state) { FactoryBot.create(:state) }
  let!(:this_case) { FactoryBot.create(:case, :with_location, state: state, title: 'Mapped Case') }

  scenario 'and sees the map from the navigation' do
    visit(root_path)

    expect(page).to have_link('Map', href: maps_path)
    expect(page).to have_link('View the case map', href: maps_path)

    within('.navbar') { click_link('Map') }

    expect(page).to have_content('Case Map')
    expect(page).to have_css('#map-container')
    expect(page).to have_content('Showing 1 documented case')
    expect(page).to have_css('#case-map-data', visible: :hidden, text: 'Mapped Case')
  end
end
