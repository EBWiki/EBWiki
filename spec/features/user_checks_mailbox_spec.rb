# frozen_string_literal: true

require 'rails_helper'

feature 'User checks mailbox' do
  let!(:user) { FactoryBot.create(:user) }
  # This is a happy path feature spec; this covers the scenario
  # where a user logs onto the site and then accesses the mailbox URL
  scenario 'Logged in user checks mailbox by accessing the mailbox URL' do
    WebMock.allow_net_connect!
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    visit '/mailbox'
    expect(page).to have_content('Inbox')
    expect(page).to have_content('Sent')
    expect(page).to have_content('Trash')
    WebMock.disable_net_connect!
  end

  # This is a happy path feature spec; this covers the scenario
  # where an anoymous user tries to access the mailbox URL
  scenario 'Anonymous user tries to check mailbox by accessing the mailbox URL' do
    visit '/mailbox'
    expect(page).to have_content('You need to sign in or sign up before continuing.')
  end
end
