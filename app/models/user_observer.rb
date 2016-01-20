class UserObserver < ActiveRecord::Observer
  observe :user

  def after_create(user)
    DeviseMailer.welcome_email(user).deliver
  end
end
