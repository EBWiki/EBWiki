# frozen_string_literal: true

# Handles User registration
module Users
  # RegistrationsController
  class RegistrationsController < Devise::RegistrationsController
    # POST /resource
    def create
      if verify_recaptcha
        super do |user|
          OnboardUser.call(user) if user.persisted?
        end
      else
        redirect_to '/users/sign_up'
      end
    end

    # The path used after sign up.
    def after_sign_up_path_for(resource)
      user_path(resource)
    end
  end
end
