# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devise::Mailer, type: :mailer do
  describe 'send_confirmation_email' do
    let!(:user) { FactoryBot.create(:user) }
    let(:mail)  { Devise.mailer.deliveries.last }

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the subject' do
      expect(mail.subject).to eql('Confirmation instructions')
    end

    it 'addresses the user' do
      expect(mail.body.encoded).to include(user.name)
    end

    it 'is polite' do
      expect(mail.body.encoded).to include('Thanks for signing up for EBWiki')
    end

    it 'prompts the user to confirm' do
      expect(mail.body.encoded).to match(/click here to confirm your account/i)
    end
  end
end
