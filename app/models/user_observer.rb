# frozen_string_literal: true

class UserObserver < ActiveRecord::Observer
  observe :user

  def after_create(user)
    UserNotifier.welcome_email(user).deliver_now
  end
end
