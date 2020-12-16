# frozen_string_literal: true

require 'rails_helper'

feature 'Editor edits an agency' do
  let(:this_agency) { FactoryBot.create(:agency) }
  let(:user) { FactoryBot.create(:user) }
  # rubocop:todo Lint/ImplicitStringConcatenation
  scenario 'Editor arrives at the agency edit page and sees the agency''s name' do
    # rubocop:enable Lint/ImplicitStringConcatenation
    login_as(user, scope: :user)
    visit "/agencies/#{this_agency.id}/edit"
    expect(page).to have_content('Editing Agency ' + this_agency.name)
  end

  scenario 'Editor arrives at the agency edit page and selects back button' do
    login_as(user, scope: :user)
    visit "/agencies/#{this_agency.id}/edit"
    expect(page).to have_content('Back to Agency')
    click_link('Back to Agency')
    expect(page.driver.status_code).to eq(200)
  end
end
