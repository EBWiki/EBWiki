# frozen_string_literal: true

class AdminNotifier < ApplicationMailer
  default from: 'EndBiasWiki@gmail.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def new_user_email(user)
    @user = user
    User.where(admin: true).each do |admin|
      mail(to: admin.email, subject: "A new user #{@user.email} has been added.")
    end
  end
end
