require "rails_helper"

RSpec.describe AnalyticsHelper, :type => :helper do
  describe "#recent_comments_by_creation_time" do
    it "should return a list of added comments" do
      article = FactoryGirl.create(:article, community_action: 'community text')
      user = FactoryGirl.create(:user)
      
      assign(:article, article)
      assign(:commentable, article)
      assign(:comment, article.comments.create(user_id: user.id))
      
      expect(helper.recent_comments_by_creation_time).to include('blockquote')
      expect(helper.recent_comments_by_creation_time).not_to include('No comments yet')
    end
    it "should give a notice message when no comments have been added" do
      expect(helper.recent_comments_by_creation_time).to include('No comments yet')
    end
  end
end