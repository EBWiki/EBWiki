require 'rails_helper'

RSpec.describe Milestone, type: :model do
  it "is invalid without a title" do
    milestone = build(:milestone, title: nil)
    expect(milestone).to be_invalid
  end

  it "must have a unique title" do
    milestone = FactoryGirl.create(:milestone, title: "Officer Indicted")
    milestone2 = build(:milestone, title: "Officer Indicted")

    expect(milestone2).to be_invalid
  end
end
