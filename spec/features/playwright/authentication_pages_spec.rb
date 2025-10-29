# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication Pages', type: :feature, js: true do
  describe 'Sign In Page' do
    it 'loads successfully' do
      visit new_user_session_path
      expect(page.status_code).to eq(200)
      expect(page).to have_current_path('/users/sign_in')
    end

    it 'displays sign in form' do
      visit new_user_session_path
      expect(page).to have_field('Email')
      expect(page).to have_field('Password')
      expect(page).to have_button('Log in')
    end

    it 'has link to sign up page' do
      visit new_user_session_path
      expect(page).to have_link('Sign up', href: '/users/sign_up')
    end

    it 'has link to forgot password' do
      visit new_user_session_path
      expect(page).to have_link('Forgot your password?', href: '/users/password/new')
    end
  end

  describe 'Sign Up Page' do
    it 'loads successfully' do
      visit new_user_registration_path
      expect(page.status_code).to eq(200)
      expect(page).to have_current_path('/users/sign_up')
    end

    it 'displays registration form' do
      visit new_user_registration_path
      expect(page).to have_field('Email')
      expect(page).to have_field('Password')
      expect(page).to have_field('Password confirmation')
      expect(page).to have_button('Sign up')
    end

    it 'has link to sign in page' do
      visit new_user_registration_path
      # Check for sign in link (may be 'Log in', 'Sign in', or just a link with href)
      expect(page.has_link?('Log in') || page.has_link?('Sign in') || page.has_link?(href: '/users/sign_in')).to be_truthy
    end
  end

  describe 'Forgot Password Page' do
    it 'loads successfully' do
      visit new_user_password_path
      expect(page.status_code).to eq(200)
      expect(page).to have_current_path('/users/password/new')
    end

    it 'displays password reset form' do
      visit new_user_password_path
      expect(page).to have_field('Email')
      expect(page).to have_button('Send me reset password instructions')
    end

    it 'has link back to sign in' do
      visit new_user_password_path
      expect(page).to have_link('Log in', href: '/users/sign_in')
    end
  end
end
