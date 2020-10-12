# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailerHelper, type: :helper do
  let(:user)                      { FactoryBot.create(:user) }
  let(:this_case)                 { FactoryBot.create(:case) }
  let(:follow_call_to_action)    { I18n.t 'notifier.follow_cases' }
  let(:follow_message)           { I18n.t 'notifier.mail_body' }
  let(:subscriber_message)       { I18n.t 'notifier.subscribe_message' }
  let(:subscribe_call_to_action) do
    I18n.t('notifier.call_to_action',
           link: ActionController::Base.helpers.link_to(I18n.t('notifier.subscribe'),
                                                        ENV['MAILCHIMP_LINK']))
  end

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
