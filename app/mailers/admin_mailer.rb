# frozen_string_literal: true

# Class responsible for sending emails about admins
class AdminMailer < ApplicationMailer
  def new_admin_email(new_admin:, recipients:)
    @new_admin = new_admin
    mail(to: recipients, subject: "A new admin has been added.")
  end
end
