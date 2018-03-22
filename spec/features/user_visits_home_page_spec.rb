# frozen_string_literal: true

require 'rails_helper'
feature 'User visits home page' do
  let!(:state) { FactoryBot.create(:state) }
  let!(:cases) { FactoryBot.create_list(:case, 20, state: state) }
  # TODO: Find a way to test the content of that selector
  scenario 'and sees the preview text on rollover' do
    visit(root_path)
    # Confirms that the links to the cases are on the page
    expect(page).to have_selector('.mask p a.info2')
    # Confirms that the article links are on the home page
    cases[0..11].each do |this_case|
      expect(page).to have_content(this_case.avatar.url)
    end
  end
end
