require 'rails_helper'

RSpec.describe ArticleMilestone, type: :model do
  it "is invalid without a milestone_id" do
    article_milestone = build(:article_milestone, milestone_id: nil)
    expect(article_milestone).to be_invalid
  end

  it "must have a date_occurred" do
    article_milestone = build(:article_milestone, date_occurred: nil)
    expect(article_milestone).to be_invalid
  end

  pending "is invalid with date in the future"
end
