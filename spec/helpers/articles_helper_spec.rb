require "rails_helper"

RSpec.describe ArticlesHelper, :type => :helper do
  describe "#embed" do
    it "returns an empty string if the video URL is blank" do
      expect(helper.embed('')).to eql("")
    end

    it "returns a content tag if the video URL is not blank" do
      expect(helper.embed('videoUrl')).to eql("<iframe src=\"//www.youtube.com/embed/videoUrl\"></iframe>")
    end

  end
end