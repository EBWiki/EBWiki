# frozen_string_literal: true

require 'rails_helper'
feature 'User visits user profile page' do
  let!(:user) { FactoryBot.create(:user) }
  let!(:state) { FactoryBot.create(:state) }
  let!(:cases) { FactoryBot.create_list(:case, 20, state: state) }

  scenario 'and sees the cases that they follow' do
    cases.each do |this_case|
      user.follow(this_case)
    end
    sign_in user
    visit("/users/#{user.id}")
    cases.each do |this_case|
      expect(page).to have_content(this_case.title)
    end
  end
end

feature 'User visits user profile page' do
  let!(:user) { FactoryBot.create(:user) }
  scenario 'and is not following any cases' do
    sign_in user
    visit("/users/#{user.id}")
    expect(page).to have_text('Please take 30 seconds')
  end
end
