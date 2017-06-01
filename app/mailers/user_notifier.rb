class UserNotifier < ApplicationMailer
  helper UserNotifierHelper
  
  default :from => 'EndBiasWiki@gmail.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_update_email(user,article)
    @user = user
    @article = article # controller getting fat with instance variables
	  mail( :to => user.email, :subject => 'A new post has been added to EBWiki' )
  end

  def send_followers_email(users, article)
    @article = article
  	users.each do|user|
      Rails.logger.info("UserNotifier#send_followers_email: Sending notification to #{user.email} about case #{article.title}")
      mail( :to => user.email, :subject => "The #{@article.title} case has been updated on EBWiki." )
    end
  end

  def notify_of_removal(users, article)
    @article = article
    users.each do|user|
      mail( :to => user.email, :subject => 'The @article.title case has been removed from EBWiki' )
    end
  end

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to EndBiasWiki')
  end
end
