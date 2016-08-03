require 'rails_helper'

RSpec.describe Document, type: :model do
  it "is invalid without a date" do
    document = build(:document, title: nil)
    expect(document).to be_invalid
  end

  it "must have a unique title" do
    document = FactoryGirl.create(:document, title: "Police Report")
    document2 = build(:document, title: "Police Report")
    expect(document2).to be_invalid
  end

end
