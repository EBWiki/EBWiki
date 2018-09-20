# frozen_string_literal: true

# application controller
class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?

  rescue_from ActionController::InvalidAuthenticityToken, with: :log_invalid_token_attempt

  if Rails.env.staging?
    http_basic_authenticate_with name: ENV['STAGING_USERNAME'], password: ENV['STAGING_PASSWORD']
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_paper_trail_whodunnit
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :state_objects
  before_action :set_paper_trail_whodunnit

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
    @state_objects ||= SortCollectionOrdinally.call(collection: State.all)
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :description, :subscribed, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :description, :subscribed, :email, :password, :password_confirmation) }
  end
end
