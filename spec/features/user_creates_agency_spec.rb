require 'rails_helper'

describe Agency do
  feature 'User Creates new Agency' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:state) { FactoryBot.create(:state) }
    scenario 'Logged in user with correct agency params' do
      collection = SortCollectionOrdinally.call(State.all)
      login_as(user, scope: :user)
      visit new_agency_path
      fill_in 'Name', with: 'Test'
      click_button 'Create Agency'
      expect(page.driver.status_code).to eq(200)
    end

    scenario 'Unsigned in user visit agency creation page' do
      visit new_agency_path
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end

    scenario 'user creates agency with in correct credentials' do
      collection = SortCollectionOrdinally.call(State.all)
      login_as(user, scope: :user)
      visit new_agency_path
      fill_in 'Name', with: ''
      click_button 'Create Agency'
      expect(page).to have_content('Please enter a name.')
    end
  end
end
