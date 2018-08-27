# frozen_string_literal: true

class UserNotifierPreview < ActionMailer::Preview
  def send_followers_email
    this_case = FactoryBot.create(:case, state_id: State.last.id + 1)
    users = User.all
    UserNotifier.send_followers_email(users, this_case)
  end

  def send_deletion_email
    this_case = FactoryBot.create(:case, state_id: 6)
    users = FactoryBot.create(:user)
    UserNotifier.send_deletion_email(user, this_case)
   end

  def welcome_email
    user = FactoryBot.create(:user)
    UserNotifier.welcome_email(user)
   end
end
