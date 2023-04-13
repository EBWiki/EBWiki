# frozen_string_literal: true

class UserMailer < ApplicationMailer
  helper UserMailerHelper

  default from: 'EndBiasWiki@gmail.com'

  def welcome_email(user:)
    @user = user
    mail(to: @user.email, subject: 'Welcome to EndBiasWiki')
  end
end
