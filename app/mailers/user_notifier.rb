class UserNotifier < ApplicationMailer
  default :from => 'team@blackopswiki.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_update_email(users,article)
    @users = users
    @article = article # controller getting fat with instance variables
    @users.each do |user|
	    mail( :to => user.email,
	    :subject => 'A new post has been added to BlackOpsWiki' )
	end
  end
end
