# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConversationMailer, type: :mailer do
  let(:sender) { FactoryBot.create(:user) }
  let(:recipient) { FactoryBot.create(:user) }
  let(:message) { sender.send_message(recipient, 'Hello there', 'A subject') }

  describe '#new_message' do
    let(:mail) { described_class.new_message(message: message, recipient: recipient) }

    it 'renders the subject and recipient' do
      expect(mail.subject).to eq('You received a new EBWiki message about A subject')
      expect(mail.to).to eq([recipient.email])
    end

    it 'includes the message body' do
      expect(mail.body.encoded).to include('Hello there')
    end
  end

  describe '#reply_message' do
    let(:reply) { recipient.reply_to(message.conversation, 'Thanks') }
    let(:mail) { described_class.reply_message(message: reply, recipient: sender) }

    it 'renders the reply subject' do
      expect(mail.subject).to eq('You received a new reply on EBWiki about A subject')
      expect(mail.to).to eq([sender.email])
    end
  end
end
