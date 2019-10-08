# frozen_string_literal: true

# This class is used when a new user is added to the site
class OnboardUser
  include Service
  def call(user)
    AddUserToMailchimp.call(user)
    UserMailer.welcome_email(user).deliver_now
  end
end
