# frozen_string_literal: true

# This class is used when a new user is added to the site.
# class UserObserver < ActiveRecord::Observer
#   observe :user

#   def after_create(user)
#     AddUserToMailchimp.call(user)
#     UserNotifier.welcome_email(user).deliver_now
#   end
# end
