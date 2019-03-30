# frozen_string_literal: true

# Class responsible for sending emails about admins
class AdminMailer < ApplicationMailer
  def new_admin_email(new_admin:, recipient:)
    @new_admin = new_admin
    @recipient = recipient
    mail(to: @recipient[1], subject: "A new admin has been added.")
  end
end
