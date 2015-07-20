require 'rails_helper'

RSpec.describe "articles/show.html.erb", type: :view do

  it 'should not display a content field' do
    article = FactoryGirl.create(:article)
    article.state = FactoryGirl.create(:state)
    assign(:article, article)
    assign(:officers, article.officers.all)
    assign(:commentable, article)
    assign(:comments, article.comments)
    assign(:comment, Comment.new)
    render
    expect(rendered).not_to match /only a stub/m
  end

  it 'displays litigation subheader if litigation text field is present' do
    article = FactoryGirl.create(:article, litigation: 'Legal Action')
    article.state = FactoryGirl.create(:state)
    assign(:article, article)
    assign(:officers, article.officers.all)
    assign(:commentable, article)
    assign(:comments, article.comments)
    assign(:comment, Comment.new)
    render
    expect(response.body).to match /Legal Action/m
  end

  it 'displays summary subheader if overview text field is present' do
    article = FactoryGirl.create(:article, overview: 'overview text')
    article.state = FactoryGirl.create(:state)
    assign(:article, article)
    assign(:officers, article.officers.all)
    assign(:commentable, article)
    assign(:comments, article.comments)
    assign(:comment, Comment.new)
    render
    expect(response.body).to match /Summary/m
  end

  it 'displays community action subheader if overview text field is present' do
    article = FactoryGirl.create(:article, community_action: 'community text')
    article.state = FactoryGirl.create(:state)
    assign(:article, article)
    assign(:officers, article.officers.all)
    assign(:commentable, article)
    assign(:comments, article.comments)
    assign(:comment, Comment.new)
    render
    expect(response.body).to match /Community and Family/m
  end

  #   describe "check for default images" do
#     it "should have the images" do
#       article = FactoryGirl.create(:article)

#       render article
#       page.should have_css('img', text: "default-user-icon.png")
#     end
#   end
end