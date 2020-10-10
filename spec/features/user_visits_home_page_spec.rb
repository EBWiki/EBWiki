# frozen_string_literal: true

require 'rails_helper'
feature 'User visits home page' do
  let!(:state) { FactoryBot.create(:state) }
  let!(:cases) { FactoryBot.create_list(:case, 12, state: state) }
  scenario 'and sees the preview text on rollover' do
    visit(root_path)
    cases.each do |this_case|
      expect(page).to have_content(this_case.title)
    end
  end
end
