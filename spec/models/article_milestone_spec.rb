require 'rails_helper'

RSpec.describe ArticleMilestone, type: :model do
    it "is invalid without a date" do
      article_milestone = build(:article_milestone, date: nil)
      expect(article_milestone).to be_invalid
    end

    it "returns the correct milestone_id" do
	  	article_milestone = build(:article_milestone)
        expect(article_milestone.milestone_id).to equal(1)
    end

    it "returns the correct description" do
	  	article_milestone = build(:article_milestone)
        expect(article_milestone.description).to include "MyText"
    end
end
