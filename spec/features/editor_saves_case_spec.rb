# frozen_string_literal: true

require 'rails_helper'

feature 'Editor edits an case' do
  let(:this_case) { FactoryBot.create(:case) }
  scenario 'Editor tries to save a case and fails' do
    user = FactoryBot.create(:user)
    login_as(user, scope: :user)
    visit "/cases/new"
    click_button "Create Case"
    expect(page).to have_content('New Case')
  end
end
