require 'rails_helper'

RSpec.describe Officer, type: :model do
  describe Officer do
    it "is invalid without a first_name" do
      officer = build(:officer, first_name: nil)
      expect(officer).to be_invalid
    end
    it "is invalid without a date" do
      officer = build(:officer, first_name: nil)
      expect(officer).to be_invalid
    end
    it "is invalid without a state_id" do
      officer = build(:officer, title: nil)
      expect(officer).to be_invalid
    end
  end
end
