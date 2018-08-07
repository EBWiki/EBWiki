# frozen_string_literal: true

require 'rails_helper'

feature 'User visits case history page' do
  let(:this_case) { FactoryBot.create(:case) }

  scenario 'User arrives at the case history page and sees history', versioning: true do
	this_case.update_attributes title: 'Case Update'
	this_case.update_attributes summary: 'New case summary'
    user = FactoryBot.create(:user)
    login_as(user, scope: :user)
    visit cases_history_path(this_case)
    expect(page).to have_text("Edited by")
  end

  let(:case_without_history) { FactoryBot.create(:case) }
  scenario 'User arrives at the case history of a null case' do
    pending
    user = FactoryBot.create(:user)
    allow(case_without_history).to receive(:versions).and_return(nil)
    login_as(user, scope: :user)
    visit cases_history_path(case_without_history)
    expect(page).to have_text("There is no history for this case." || "There is no history for this Agency.")
  end
end
