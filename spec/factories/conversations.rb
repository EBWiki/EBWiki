# frozen_string_literal: true

FactoryBot.define do
  factory :conversation, class: Mailboxer::Conversation do
    subject { 'Something you might be interested in' }
    body { 'What you want to see' }
  end
end
