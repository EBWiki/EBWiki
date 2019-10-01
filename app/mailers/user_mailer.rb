# frozen_string_literal: true

class UserMailer < ApplicationMailer
  helper UserMailerHelper

  default from: 'EndBiasWiki@gmail.com'

  def send_followers_email(users, this_case)
    @this_case = this_case
    users.each do |user|
      Rails.logger.info("UserMailer#send_followers_email: Sending notification to #{user.email} about case #{this_case.title}")
      mail(to: user.email, subject: "The #{@this_case.title} case has been updated on EBWiki.")
    end
  end

  def send_deletion_email(users, this_case)
    @this_case = this_case
    users.each do |user|
      Rails.logger.info("UserMailer#send_deletion_email: Sending notification to #{user.email} about case #{this_case.title}")
      mail(to: user.email, subject: "The #{@this_case.title} case has been removed from EBWiki")
    end
  end

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to EndBiasWiki')
  end
end
