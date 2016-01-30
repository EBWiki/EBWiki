require 'rails_helper'

RSpec.describe "articles/show.html.erb", type: :view do
  before do
    controller.singleton_class.class_eval do
      protected
        def marker_locations_for(articles)
          [Article.all]
        end
        helper_method :marker_locations_for
    end
  end
  describe "on success" do
     it 'should not display a content field' do
      article = FactoryGirl.create(:article)
      article.state = FactoryGirl.create(:state)
      assign(:article, article)
      assign(:officers, article.officers.all)
      assign(:commentable, article)
      assign(:comments, article.comments)
      assign(:comment, Comment.new)
      assign(:subjects, article.subjects)
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
      assign(:subjects, article.subjects)
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
      assign(:subjects, article.subjects)
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
      assign(:subjects, article.subjects)
      render
      expect(response.body).to match /Community and Family/m
    end
  end
end