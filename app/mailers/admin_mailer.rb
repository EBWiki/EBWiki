# frozen_string_literal: true

class AdminMailer < ApplicationMailer

  # send a signup email to the user, pass in the user object that contains the user's email address
  def new_admin_email(new_admin:, recipient:)
    @new_admin = new_admin
    @recipient = recipient
    mail(to: @recipient[1], subject: "A new admin has been added.")
  end
end
