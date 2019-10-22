# frozen_string_literal: true

require 'rails_helper'

feature 'Editor edits a case' do
  let(:this_case) { FactoryBot.create(:case) }
  let(:user) { FactoryBot.create(:user) }
  scenario 'Editor arrives at the case edit page and sees the subject''s name' do

    login_as(user, scope: :user)
    visit "/cases/#{this_case.id}/edit"
    expect(page).to have_content('Editing Case ' + this_case.title)
  end

  scenario 'Editor arrives at the case edit page and selects back button' do

    login_as(user, scope: :user)
    visit "/cases/#{this_case.id}/edit"
    expect(page).to have_content('Back to Case')
    click_button('Back to Case')
    expect(page).to eq "/cases/#{this_case.id}"
  end


end
