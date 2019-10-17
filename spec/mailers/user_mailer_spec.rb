# frozen_string_literal: true

require 'rails_helper'
PaperTrail.request.disable_model(Case)
RSpec.describe UserMailer, type: :mailer do
  before(:each) do
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end
  
  describe 'welcome_email' do
    let(:user)      { FactoryBot.create(:user) }
    let(:this_case) { FactoryBot.create(:case) }
    let!(:mail)     { UserMailer.welcome_email(user: user) }

    it 'renders the subject and receiver email' do
      expect(mail.subject).to eql('Welcome to EndBiasWiki')
      expect(mail.to).to eq([user.email])
    end

    it 'renders the proper message when user has followed 1 or more cases' do
      user.follow(this_case)
      expect(mail.body.encoded.gsub(/\s+/, '')).to include(I18n.t('notifier.mail_body')
                                                               .gsub(/\s+/, ''))
      expect(mail.body.encoded.gsub(/\s+/, '')).not_to include(I18n.t('notifier.follow_cases')
                                                                   .gsub(/\s+/, ''))
    end
  end

  describe 'send_confirmation_email' do
    pending
    let(:user)      { FactoryBot.create(:user) }
    let(:this_case) { FactoryBot.create(:case) }
    let!(:mail)     { UserMailer.welcome_email(user: user) }

    it 'renders the subject and receiver email' do
      pending
      expect(mail.subject).to eql('Confirm your email address')
      expect(mail.to).to eq([user.email])
    end

    it 'renders the proper message' do
      pending
      user.follow(this_case)
      expect(mail.body.encoded.gsub(/\s+/, '')).to include(I18n.t('notifier.confirmation_message')
                                                              .gsub(/\s+/, ''))
    end
  end
end
