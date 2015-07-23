class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :mailbox, :conversation

  def info_for_paper_trail
  # Save additional info
	{ ip: request.remote_ip }
  end

  def user_for_paper_trail
  # Save the user responsible for the action
	user_signed_in? ? current_user.id : 'Guest'
  end

private
 
  def mailbox
    @mailbox ||= current_user.mailbox
  end

  def conversation
    @conversation ||= mailbox.conversations.find(params[:id])
  end

protected
 
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up)  {|u| u.permit(:name, :description, :subscribed, :email, :password, :password_confirmation)}
    devise_parameter_sanitizer.for(:account_update)  {|u| u.permit(:name, :description, :subscribed, :email, :password, :password_confirmation)}
  end
end
