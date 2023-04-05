# frozen_string_literal: true

require 'rails_helper'

describe User do
  feature 'Anonymous User' do
    # This is a feature spec where a user tries to log onto the
    # main site as well as the admin section, but does not have
    # the proper credentials for either section of the site.
    # In this case the user should get a login error message and not
    # be able to log into the admin section of the site.
    scenario 'without sign in' do
      visit new_user_session_path
      click_button 'Log in'
      expect(page).to have_content 'Invalid Email or password'
      visit rails_admin.dashboard_path
      expect(page).to have_content 'You are not an admin'
    end
  end

  feature 'User signs in' do
    let!(:user) { FactoryBot.create(:user) }
    # This is a happy path feature spec; this covers the scenario
    # where a user log into the site section, but
    # does not have the proper credentials access the admin section,
    # which it then attempts to access. In this case
    # the user should not get a login error message, but not
    # be able to log into the admin section of the site.
    scenario 'without admin credentials' do
      pending
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'
      visit rails_admin.dashboard_path
      expect(page).to have_content 'You are not an admin'
      WebMock.disable_net_connect!
    end
  end

  feature 'Admin signs in' do
    let!(:admin) { FactoryBot.create(:admin) }

    # This is a happy path feature spec; this covers the scenario
    # where an admin user logs into the site section and has
    # the proper credentials access the admin section,
    # which it then attempts to access. In this case
    # the user should not get a login error message, and  be able
    # to log into the admin section of the site.
    scenario 'with admin credentials' do
      WebMock.allow_net_connect!
      visit new_user_session_path
      fill_in 'Email', with: admin.email
      fill_in 'Password', with: admin.password
      click_button 'Log in'
      visit rails_admin.dashboard_path
      expect(page).to have_content 'Site Administration'
      WebMock.disable_net_connect!
    end

    # This is a failure feature spec; this covers the scenario
    # where a user tries to log into the admin section, but
    # does not have the proper credentials to do so. In this case
    # the user should get an error message and not be able to log
    # into the admin section of the site.
    scenario 'with incorrect admin credentials' do
      visit new_user_session_path
      fill_in 'Email', with: admin.email
      fill_in 'Password', with: 'bad_password'
      click_button 'Log in'
      expect(page).to have_content 'Invalid Email or password'
      visit rails_admin.dashboard_path
      expect(page).to have_content 'You are not an admin'
    end

    # This is a failure feature spec; this covers the scenario
    # where a user tries to log into the admin section without entering
    # any information on the login form. In this case
    # the user should get an error message and not be able to log
    # into the admin section of the site.
    scenario 'without any credentials' do
      visit new_user_session_path
      click_button 'Log in'
      expect(page).to have_content 'Invalid Email or password'
      visit rails_admin.dashboard_path
      expect(page).to have_content 'You are not an admin'
    end
  end
end
