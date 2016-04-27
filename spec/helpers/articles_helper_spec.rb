require "rails_helper"

RSpec.describe ArticlesHelper, :type => :helper do
  describe "#embed" do
    it "returns an empty string if the video URL is blank" do
      expect(helper.embed('')).to eql("")
    end

    it "returns a content tag if youtube video URL is provided" do
      expect(helper.embed('https://www.youtube.com/watch?v=Mgn1r3_eM-s')).to eql("<iframe src=\"//www.youtube.com/embed/Mgn1r3_eM-s\"></iframe>")
    end

    it "returns a content tag if vimeo video URL is provided" do
      expect(helper.embed('https://vimeo.com/136536466')).to eql("<iframe src=\"https://player.vimeo.com/video/136536466\"></iframe>")
    end

  end

  # These specs confirm that the article_sanity_check works as expected
  # If there is data that is not available, then the sanity_check returns
  # false. At that point, the site can throw an error or redirect to
  # another page. This is a more graceful solution that making the error
  # page available.

  describe "#article_sanity_check" do
    it "returns true if all the instance variables needed for the article are present" do
      article = FactoryGirl.create(:article, community_action: 'community text')
      article.state = FactoryGirl.create(:state)
      assign(:article, article)
      assign(:commentable, article)
      assign(:comment, Comment.new)
      assign(:subjects, article.subjects)
      expect(helper.article_sanity_check).to be_truthy
    end

    it "returns false if any of the instance variables needed for the article are not present" do
      article = FactoryGirl.create(:article, community_action: 'community text')
      article.state = FactoryGirl.create(:state)
      assign(:article, article)
      assign(:commentable, article)
      assign(:comment, Comment.new)
      expect(helper.article_sanity_check).to be_falsey
    end
  end

end