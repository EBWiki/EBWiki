# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/user_notifier
class UserNotifierPreview < ActionMailer::Preview
  def send_followers_email
    UserNotifier.send_followers_email([User.first], Case.last)
  end
end
