require 'rails_helper'

feature "User follows an article from show" do
	let(:article) { FactoryGirl.create(:article) }
	scenario "User arrives at the article show page and clicks to follow" do
		user = FactoryGirl.create(:user)
		login_as(user, :scope => :user)
		visit article_path(article)
		click_link 'Follow'
		expect(article.followers.count).to eq(1)
	end

	scenario "User arrives at the article show page and clicks to unfollow" do
	  
		user = FactoryGirl.create(:user)
		login_as(user, :scope => :user)
		visit article_path(article)
		click_link 'Follow'
		click_link 'Unfollow'
		expect(article.followers.count).to eq(0)
	end
end

feature "Non-logged in user attempts to follow an article from show" do
	let(:article) { FactoryGirl.create(:article) }
	scenario "User arrives at the article show page and clicks to follow" do
	  
		visit article_path(article)
		click_link 'Follow'
		expect(current_path).to eq("/users/sign_in")
	end
end

# feature "User follows an article from followers page" do
# 	let(:article) { FactoryGirl.create(:article) }
# 	scenario "User arrives at the article show page and clicks to follow" do
# 	  
# 		user = FactoryGirl.create(:user)
# 		login_as(user, :scope => :user)
# 		visit articles_followers_path(article)
# 		click_link 'Track this case'
# 		expect(article.followers.count).to eq(1)
# 	end
# end