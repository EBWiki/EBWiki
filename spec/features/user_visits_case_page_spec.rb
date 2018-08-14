# frozen_string_literal: true

require 'rails_helper'

feature 'User visits a case' do
  let(:this_case) { FactoryBot.create(:case) }
  scenario ' User visits a case using the current case id' do
    visit "/cases/#{this_case.id}"
    expect(page.driver.status_code).to eq(301)
  end

  scenario ' User visits a case using the old case id' do
    visit case_path(this_case)
    expect(page.driver.status_code).to eq(200)
  end
end
