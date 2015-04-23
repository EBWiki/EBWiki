require 'rails_helper'

  describe User do
    feature 'Anonymous User' do 
      scenario 'without sign in' do
        visit rails_admin.dashboard_path
        expect(page).to have_content "You are not an admin"
      end
    end

    feature 'User signs in' do
      let!(:user) { FactoryGirl.create(:user) }
     
      scenario 'without admin credentials' do
        visit new_user_session_path
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Log in'
        visit rails_admin.dashboard_path
        expect(page).to have_content "You are not an admin"
      end
    end

    feature 'Admin signs in' do
      let!(:admin) { FactoryGirl.create(:admin) }
     
      scenario 'with admin credentials' do
        visit new_user_session_path
        fill_in 'Email', with: admin.email
        fill_in 'Password', with: admin.password
        click_button 'Log in'
        visit rails_admin.dashboard_path
        expect(page).to have_content "Site Administration"
      end
    end
  end