# frozen_string_literal: true

require 'rails_helper'
PaperTrail.enabled = false
RSpec.describe UserNotifier, type: :mailer do
  describe 'send_followers_email' do
    let(:follower) { mock_model User, name: 'A Follower', email: 'follower@ebwiki.org' }
    let(:author) { mock_model User, name: 'John', email: 'john@email.com' }
    let(:this_case) { mock_model Case, title: 'John Smith', content: 'some content', state_id: 33 }
    let(:mail) { UserNotifier.send_followers_email([follower], this_case) }

    before do
      allow(this_case).to receive_message_chain('versions.last.whodunnit').and_return(User.last)
      allow(this_case).to receive_message_chain('versions.last.comment').and_return('Comment')
      allow(Rails.logger).to receive(:info)
      allow(User).to receive(:find).and_return(author)
    end

    it 'renders the subject' do
      expect(mail.subject).to eql("The #{this_case.title} case has been updated on EBWiki.")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([follower.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['EndBiasWiki@gmail.com'])
    end

    it 'includes @user.name' do
      expect(mail.body.encoded).to match(author.name)
    end
  end
end

RSpec.describe UserNotifier, type: :mailer do
  describe 'notify_of_removal' do
    let(:follower) { mock_model User, name: 'A Follower', email: 'follower@ebwiki.org' }
    let(:this_case)  { mock_model Case, title: 'John Smith', content: 'some content', state_id: 33 }
    let(:mail) { UserNotifier.send_deletion_email([follower], this_case) }

    it 'renders the subject' do
      expect(mail.subject).to eql("The #{this_case.title} case has been removed from EBWiki")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([follower.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['EndBiasWiki@gmail.com'])
    end
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
      expect(mail.body.encoded).to include('You have already taken the first step by following 1 case on EBWiki and allowing us to keep you up to date.')
      expect(mail.body.encoded).not_to include('It is very important that you click to follow one or more cases and allow us to keep you up to date. The more people paying attention, the easier it will be effect change.')
    end
  end
end
