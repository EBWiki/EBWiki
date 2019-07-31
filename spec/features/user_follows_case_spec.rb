# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'the follow process', type: :feature do
  let(:this_case) { FactoryBot.create(:case) }
  let(:user) { FactoryBot.create(:user) }

  it 'shows the follow link when user visits case page' do
    login_as(user, scope: :user)
    visit case_path(this_case)
    click_button 'Follow'
    visit case_path(this_case)
    expect(page).to have_button('Unfollow')
  end

  it 'shows the unfollow link if user is already following case' do
    login_as(user, scope: :user)
    user.follow(this_case)
    visit case_path(this_case)
    click_button 'Unfollow'
    expect(page).to have_button('Follow')
  end

  it 'shows redirects to sign in page when visitor clicks follow' do
    visit case_path(this_case)
    click_button 'Follow'
    expect(current_path).to eq('/users/sign_in')
  end
end
