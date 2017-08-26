require 'rails_helper'
feature "User visits home page" do
	let!(:state) { FactoryGirl.create(:state)}
	let!(:articles) { FactoryGirl.create_list(:article, 20, state: state) }
	# TODO: Find a way to test the content of that selector
	scenario "and sees the preview text on rollover" do
		visit(root_path)
		# Confirms that the links to the cases are on the page
		expect(page).to have_selector(".mask p a.info2")
		# Confirms that the article links are on the home page
		articles[0..11].each do |article|
			expect(page).to have_content(article.avatar.url)	
		end
	end
end
