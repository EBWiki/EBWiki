# frozen_string_literal: true

# This service object determines and sends the correct email when a user's admin status is changed.
class SendAdminEmail
  include Service

  def call(user:)
    previous_admin_status = user.previous_changes['admin']
    send_new_admin_email(user: user) if previous_admin_status[1]
  end

  private

  def send_new_admin_email(user:)
    admin_emails = User.where.not(email: user.email).where(admin: true).pluck(:email)
    AdminMailer.new_admin_email(new_admin: user, recipients: admin_emails).deliver_now
  end
end
