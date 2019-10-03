# frozen_string_literal: true

require 'rails_helper'
PaperTrail.request.disable_model(Case)
RSpec.describe UserNotifier, type: :mailer do
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
    let!(:mail)     { UserNotifier.welcome_email(user) }

    it 'renders the subject and receiver email' do
      expect(mail.subject).to eql('Welcome to EndBiasWiki')
      expect(mail.to).to eq([user.email])
    end

    it 'renders the proper message when user has followed 1 or more cases' do
      user.follow(this_case)
      expect(mail.body.encoded.gsub(/\s+/, '')).to include('You have already taken the first step by following 1 case on EBWiki and allowing us to keep you up to date.'.gsub(/\s+/, ''))
      expect(mail.body.encoded.gsub(/\s+/, '')).not_to include("It is very important that you click to follow one or more cases and allow us to keep\nyou up to date. The more people paying attention, the easier it will be effect change.".gsub(/\s+/, ''))
    end
  end
end
