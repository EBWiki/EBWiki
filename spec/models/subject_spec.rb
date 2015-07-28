require 'rails_helper'

RSpec.describe Subject, type: :model do

    it "is invalid without a name" do
      subject = build(:subject, name: nil)
      expect(subject).to be_invalid
    end
  
    it "must have a unique name" do
      subject = build(:subject, name: 'john smith')
      subject.save
      subject2 = build(:subject, name: 'john smith')
      expect(subject2).to be_invalid
    end
end
