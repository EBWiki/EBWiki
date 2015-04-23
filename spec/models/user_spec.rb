require 'rails_helper'

  describe User do
    it "by default isn't admin" do
      expect(User.new).to_not be_admin
    end

    it "does not have access to rails_admin if not admin" do
      user = build(:user, admin: false)
      expect(article).to be_invalid
    end
 
    it "has access to rails_admin if admin" do
      user = build(:user, admin: true)
      expect(article).to be_invalid
    end
  end