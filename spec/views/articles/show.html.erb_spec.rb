require 'rails_helper'

RSpec.describe "articles/show.html.erb", type: :view do

  it 'displays content field if content field is not blank' do
  	article = FactoryGirl.create(:article)
  	article.state = FactoryGirl.create(:state)
  	assign(:article, article)
  	assign(:officers, article.officers.all)
  	assign(:commentable, article)
  	assign(:comments, article.comments)
  	assign(:comment, Comment.new)
  	render
  	expect(rendered).to match /new article/
  end

  # 	describe "check for default images" do
# 	  it "should have the images" do
# 	  	article = FactoryGirl.create(:article)

# 	  	render article
# 	    page.should have_css('img', text: "default-user-icon.png")
# 	  end
# 	end
end