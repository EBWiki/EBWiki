# frozen_string_literal: true

# Preview all emails at http://localhost:3000/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview

  def new_admin_email
    AdminMailer.new_admin_email(user: User.find_by(admin: true), recipients: User.last.pluck(:email))
  end
end