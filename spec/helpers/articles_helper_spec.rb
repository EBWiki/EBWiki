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

  # describe "#marker_locations_for" do

  #   let(:articles) { FactoryGirl.create_list(:article, 4) }

  #   it "returns a hash with location data" do
  #   	expect(helper.marker_locations_for(articles)).to_not be_empty
  #   end

  #   it "returns nothing if articles are blank" do
  #     expect(helper.marker_locations_for(nil)).to be_blank
  #   end
  # end
end