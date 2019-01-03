# frozen_string_literal: true

require 'rails_helper'

feature 'User follows an case from show' do
  scenario 'User arrives at the case show page and clicks to follow' do
    user = FactoryBot.create(:user)
    this_case = FactoryBot.create(:case)
    login_as(user, scope: :user)
    visit case_path(this_case)
    click_link 'Follow'
    expect(page).to have_content('Unfollow')
  end

  scenario 'User arrives at the case show page and clicks to unfollow' do
    user = FactoryBot.create(:user)
    this_case = FactoryBot.create(:case)
    user.follow(this_case)
    login_as(user, scope: :user)
    visit case_path(this_case)
    click_link 'Unfollow'
    expect(page).to have_link('Follow')
  end
end

feature 'Non-logged in user attempts to follow an case from show' do
  let(:this_case) { FactoryBot.create(:case) }
  scenario 'User arrives at the case show page and clicks to follow' do
    visit case_path(this_case)
    click_link 'Follow'
    expect(current_path).to eq('/users/sign_in')
  end
end

