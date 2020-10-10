# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def send_followers_email
    UserMailer.send_followers_email(users: [User.first], this_case: Case.last)
  end

  def send_delection_email
    UserMailer.send_delection_email(users: [User.first], this_case: Case.last)
  end

  def send_welcome_email
    UserMailer.send_welcome_email([User.first])
  end
end
