require 'rails_helper'

feature "Editor edits an article" do
	let(:article) { FactoryGirl.create(:article) }
	scenario "Editor arrives at the article edit page and sees the subject's name" do
		user = FactoryGirl.create(:user)
		login_as(user, :scope => :user)
		visit "/articles/#{article.id}/edit"
		expect(page).to have_content('Edit Case for "' + article.subjects.first.name + '"')
	end
end