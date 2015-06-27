require 'rails_helper'

RSpec.describe "articles/show.html.erb", type: :view do
  it 'displays content field if content field is not blank' do
  	article = FactoryGirl.create(:article)

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