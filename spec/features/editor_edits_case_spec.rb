# frozen_string_literal: true

require 'rails_helper'

feature 'Editor edits an case' do
  let(:this_case) { FactoryBot.create(:case) }
  scenario "Editor arrives at the case edit page and sees the subject's name" do
    user = FactoryBot.create(:user)
    login_as(user, scope: :user)
    visit "/cases/#{this_case.id}/edit"
    expect(page).to have_content('Edit Case for "' + this_case.subjects.first.name + '"')
  end
end
