# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActionController::InvalidAuthenticityToken, with: :log_invalid_token_attempt

  if Rails.env.staging?
    http_basic_authenticate_with name: ENV['STAGING_USERNAME'], password: ENV['STAGING_PASSWORD']
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :state_objects

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

  def log_invalid_token_attempt
    warning_message = 'Invalid Auth Token error'
    Rails.logger.warn warning_message
    Rollbar.warning warning_message
    redirect_to '/'
  end

  def state_objects
    @state_objects ||= State.all
  end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :description, :subscribed, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :description, :subscribed, :email, :password, :password_confirmation) }
  end
end
