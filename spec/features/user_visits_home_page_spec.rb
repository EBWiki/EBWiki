require 'rails_helper'
require 'pp'
feature "User visits home page" do
	let!(:state) { FactoryGirl.create(:state)}
	let!(:articles) { FactoryGirl.create_list(:article, 20, state: state) }
	# This test confirms that the element with the class description exists
	# TODO: Find a way to test the content of that selector
	scenario "and sees the preview text on rollover" do
		visit(root_path)
		expect(page).to have_selector(".mask p a.info2")
	end
end
