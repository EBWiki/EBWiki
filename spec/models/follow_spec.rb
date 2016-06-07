require 'rails_helper'

# RSpec.describe Follow, type: :model do

#   it "is invalid without a name" do
#     subject = build(:subject, name: nil)
#     expect(subject).to be_invalid
#   end
# end

describe "total follow growth rate" do
  it "returns the correct percentage increase" do
    follow = FactoryGirl.create(:follow, created_at: 31.days.ago)
    follow2 = FactoryGirl.create(:follow)
    expect(Follow.first.mom_follows_growth).to eq(100)
  end
end