# frozen_string_literal: true

# Class responsible for sending emails about admins
class AdminMailer < ApplicationMailer
  def new_admin_email(new_admin:, recipients:)
    @new_admin = new_admin
    mail(to: recipients, subject: 'A new admin has been added.')
  end

  def remove_admin_email(removed_admin:, recipients:)
    @removed_admin = removed_admin
    mail(to: recipients, subject: "#{@removed_admin.name} is no longer an admin.")
  end
end
