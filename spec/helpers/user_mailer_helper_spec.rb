# frozen_string_literal: true

require 'rails_helper'

<<<<<<< HEAD:spec/helpers/user_notifier_helper_spec.rb
RSpec.describe UserNotifierHelper, type: :helper do
  let(:user)                     { FactoryBot.create(:user) }
  let(:this_case)                { FactoryBot.create(:case) }
  let(:follow_call_to_action)    { I18n.t 'notifier.follow_cases' }
  let(:follow_message)           { I18n.t 'notifier.mail_body' }
  let(:subscriber_message)       { I18n.t 'notifier.subscribe_message' }
  let(:subscribe_call_to_action) do
    I18n.t('notifier.call_to_action',
           link: ActionController::Base.helpers.link_to(I18n.t('notifier.subscribe'),
                                                        ENV['MAILCHIMP_LINK']))
  end
=======
RSpec.describe UserMailerHelper, type: :helper do
  let(:user)                      { FactoryBot.create(:user) }
  let(:this_case)                 { FactoryBot.create(:case) }
  let(:follow_call_to_action)     { "It is very important that you click to follow one or more cases and allow us to keep\nyou up to date. The more people paying attention, the easier it will be to affect change.\n" }
  let(:follow_message)            { 'You have already taken the first step by following 1 case on EBWiki and allowing us to keep you up to date.' }
  let(:subscribe_call_to_action)  { "#{ActionController::Base.helpers.link_to('Subscribe to our newsletter as well', ENV['MAILCHIMP_LINK'])} for periodic general updates and commentaries on this issue." }
  let(:subscriber_message)        { "As a newsletter subscriber, you'll receive our general updates periodically." }
>>>>>>> c23c0eaab28a495615df0e84956762bbb04189b6:spec/helpers/user_mailer_helper_spec.rb

  describe 'create_welcome_email_message' do
    it 'generates the message for an unsubscribed user with no followed cases' do
      expected_message = follow_call_to_action + ' ' + subscribe_call_to_action
      actual_message = create_welcome_email_message(user, false)
      expect(actual_message.gsub(/\s+/, '')).to eq expected_message.gsub(/\s+/, '')
    end

    it 'generates the message for an unsubscribed user that follows 1 case' do
      expected_message = follow_message + ' ' + subscribe_call_to_action
      user.follow(this_case)
      actual_message = create_welcome_email_message(user, false)
      expect(actual_message.gsub(/\s+/, '')).to eq(expected_message.gsub(/\s+/, ''))
    end

    it 'generates the message for a subscribed user with no followed cases' do
      expected_message = follow_call_to_action + ' ' + subscriber_message
      actual_message = create_welcome_email_message(user, true)
      expect(actual_message.gsub(/\s+/, '')).to eq expected_message.gsub(/\s+/, '')
    end

    it 'generates the message for a subscribed user that follows 1 case' do
      expected_message = follow_message + ' ' + subscriber_message
      user.follow(this_case)
      actual_message = create_welcome_email_message(user, true)
      expect(actual_message.gsub(/\s+/, '')).to eq expected_message.gsub(/\s+/, '')
    end
  end
end
