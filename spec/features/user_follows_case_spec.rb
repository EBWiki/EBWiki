# frozen_string_literal: true

require 'rails_helper'

feature 'User follows an case from show' do
  let!(:this_case) { FactoryBot.create(:case) }
  scenario 'User arrives at the case show page and clicks to follow' do
    user = FactoryBot.create(:user)
    login_as(user, scope: :user)
    visit case_path(this_case)
    click_link 'Follow'
    expect(this_case.followers.count).to eq(1)
  end

  scenario 'User arrives at the case show page and clicks to unfollow' do
    user = FactoryBot.create(:user)
    login_as(user, scope: :user)
    visit case_path(this_case)
    click_link 'Follow'
    click_link 'Unfollow'
    expect(this_case.followers.count).to eq(0)
  end
end

feature 'Non-logged in user attempts to follow an case from show' do
  let!(:this_case) { FactoryBot.create(:case) }
  scenario 'User arrives at the case show page and clicks to follow' do
    visit case_path(this_case)
    click_link 'Follow'
    expect(current_path).to eq('/users/sign_in')
  end
end

