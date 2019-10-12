# frozen_string_literal: true

# This service object determines and sends the correct email when a user's admin status is changed.
class SendAdminEmail
  include Service

  def call(user:)
    # returns an array [false, true] or [true, false]
    previous_admin_status = user.previous_changes['admin']
    send_new_admin_email(user: user)
    
    if previous_admin_status[1]
      send_new_admin_email(user: user)
    elsif previous_admin_status[1] == false
      send_removed_admin_email(user: user)
    end
  end

  private

  def send_new_admin_email(user:)
    AdminMailer.new_admin_email(new_admin: user, recipients: admin_emails(user: user)).deliver_now
  end
  
  def send_removed_admin_email(user:)
    AdminMailer.remove_admin_email(removed_admin: user, recipients: admin_emails(user: user)).deliver_now
  end
  
  def admin_emails(user:)
    User.where.not(email: user.email).where(admin: true).pluck(:email)
  end
end
