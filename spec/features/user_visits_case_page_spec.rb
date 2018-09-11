# frozen_string_literal: true

require 'rails_helper'

feature 'User visits a case' do
  let(:this_case) { FactoryBot.create(:case, title: 'old title') }
  scenario 'User visits a case using the old case title' do
    this_case.update_attributes title: 'new title'
    visit '/cases/old-title'
    expect(page).to have_current_path('/cases/new-title')
  end
end
