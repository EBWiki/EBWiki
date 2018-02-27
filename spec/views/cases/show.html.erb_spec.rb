# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'articles/show.html.erb', type: :view do
  before do
    controller.singleton_class.class_eval do
      protected

        def marker_locations_for(_articles)
          [Article.all]
        end
        helper_method :marker_locations_for
    end
  end
  describe 'on success' do
    it 'should not display a content field' do
      article = FactoryBot.create(:article)
      assign(:article, article)
      assign(:commentable, article)
      assign(:comments, article.comments)
      assign(:comment, Comment.new)
      assign(:subjects, article.subjects)
      assign(:state_objects, State.all)
      render
      expect(rendered).not_to match /only a stub/m
    end

    it 'displays litigation subheader if litigation text field is present' do
      article = FactoryBot.create(:article, litigation: 'Legal Action')

      assign(:article, article)
      assign(:commentable, article)
      assign(:comments, article.comments)
      assign(:comment, Comment.new)
      assign(:subjects, article.subjects)
      assign(:state_objects, State.all)
      render
      expect(response.body).to match /Legal Action/m
    end

    it 'displays summary subheader if overview text field is present' do
      article = FactoryBot.create(:article, overview: 'overview text')

      assign(:article, article)
      assign(:commentable, article)
      assign(:comments, article.comments)
      assign(:comment, Comment.new)
      assign(:subjects, article.subjects)
      assign(:state_objects, State.all)
      render
      expect(response.body).to match /Summary/m
    end

    it 'displays community action subheader if overview text field is present' do
      article = FactoryBot.create(:article, community_action: 'community text')

      assign(:article, article)
      assign(:commentable, article)
      assign(:comments, article.comments)
      assign(:comment, Comment.new)
      assign(:subjects, article.subjects)
      assign(:state_objects, State.all)
      render
      expect(response.body).to match /Community and Family/m
    end
  end
end
