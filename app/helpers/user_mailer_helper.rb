# frozen_string_literal: true

# Set of helper methods for composing email messages
module UserMailerHelper
  FOLLOW_CALL_TO_ACTION = <<~"FCTA"
    It is very important that you click to follow one or more cases and allow us to keep
    you up to date. The more people paying attention, the easier it will be to affect change.
  FCTA

  SUBSCRIBER_MESSAGE = "As a newsletter subscriber, you'll \
    receive our general updates periodically."

  subscriber_link_copy = 'Subscribe to our newsletter as well'
  subscriber_link = ActionController::Base.helpers.link_to(
    subscriber_link_copy, ENV['MAILCHIMP_LINK']
  )
  SUBSCRIBER_CALL_TO_ACTION = "#{subscriber_link} for periodic" \
                              'general updates and commentaries on this issue.'

  def create_welcome_email_message(user, is_subscribed)
    followed_cases = user.all_following.count
    follow_cases_message(followed_cases) + ' ' + subscribe_message(is_subscribed)
  end

  def follow_cases_message(followed_cases)
    return FOLLOW_CALL_TO_ACTION if followed_cases.zero?

    "You have already taken the first step by following \
      #{pluralize(followed_cases, 'case')} \
      on EBWiki and allowing us to keep you up to date."
  end

  def subscribe_message(is_subscribed)
    return SUBSCRIBER_MESSAGE if is_subscribed

    SUBSCRIBER_CALL_TO_ACTION
  end
end
