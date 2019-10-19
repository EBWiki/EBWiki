# frozen_string_literal: true

# Handles User registration
class Users::RegistrationsController < Devise::RegistrationsController
  # POST /resource
  def create
    if verify_recaptcha
      super
      OnboardUser.call(resource)
    else
      redirect_to '/users/sign_up'
    end
  end

  # The path used after sign up.
  def after_inactive_sign_up_path_for(resource)
    user_path(resource)
  end
end
