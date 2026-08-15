# frozen_string_literal: true

require 'rails_helper'

feature 'User checks mailbox' do
  let!(:user) { FactoryBot.create(:user) }

  scenario 'Logged in user checks mailbox by accessing the mailbox URL' do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    visit '/mailbox'
    expect(page).to have_content('Inbox')
    expect(page).to have_content('Sent')
    expect(page).to have_content('Trash')
  end

  scenario 'Anonymous user tries to check mailbox by accessing the mailbox URL' do
    visit '/mailbox'
    expect(page).to have_content('You need to sign in or sign up before continuing.')
  end
end
