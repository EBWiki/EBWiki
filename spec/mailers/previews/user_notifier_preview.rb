# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/user_notifier
class UserNotifierPreview < ActionMailer::Preview
  def send_followers_email
    CaseMailer.send_followers_email(users: [User.first], this_case: Case.last)
  end
end
