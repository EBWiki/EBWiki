class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def info_for_paper_trail
  # Save additional info
	{ ip: request.remote_ip }
  end

  def user_for_paper_trail
  # Save the user responsible for the action
	user_signed_in? ? current_user.id : 'Guest'
  end
end
