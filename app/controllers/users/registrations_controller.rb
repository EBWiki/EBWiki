# frozen_string_literal: true

# Handles User registration
class Users::RegistrationsController < Devise::RegistrationsController
  # POST /resource
  def create
    super
    OnboardUser.call(resource)
  end


  # The path used after sign up.
  def after_sign_up_path_for(resource)
    user_path(resource)
  end
end
