# frozen_string_literal: true

class AdminNotifierPreview < ActionMailer::Preview
  def new_user_email
    user = FactoryBot.create(:user, admin: true)
    AdminNotifier.new_user_email(user)
  end
end
