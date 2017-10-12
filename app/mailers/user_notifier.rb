# frozen_string_literal: true

class UserNotifier < ApplicationMailer
  default from: 'EndBiasWiki@gmail.com'

  def send_followers_email(users, article)
    @article = article
    users.each do |user|
      Rails.logger.info("UserNotifier#send_followers_email: Sending notification to #{user.email} about case #{article.title}")
      mail(to: user.email, subject: "The #{@article.title} case has been updated on EBWiki.")
    end
  end

  def send_deletion_email(users, article)
    @article = article
    users.each do|user|
      Rails.logger.info("UserNotifier#send_deletion_email: Sending notification to #{user.email} about case #{article.title}")
      mail( :to => user.email, :subject => 'The @article.title case has been removed from EBWiki' )
    end
  end

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to EndBiasWiki')
  end
end
