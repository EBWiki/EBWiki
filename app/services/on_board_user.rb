module OnboardUser
  include Service
  def call(user)
    AddUserToMailchimp.call(user)
    UserNotifier.welcome_email(user).deliver_now
  end
end