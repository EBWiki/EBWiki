# frozen_string_literal: true

require 'rails_helper'
RSpec.describe CaseMailer, type: :mailer do
  before(:each) do
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe 'send_followers_email' do
    let(:follower) { FactoryBot.create(:user, name: 'A Follower', email: 'follower@ebwiki.org') }
    let(:author) { FactoryBot.create(:user, name: 'John', email: 'john@email.com') }
    let(:user) { FactoryBot.create(:user) }
    let(:state) { FactoryBot.create(:state, id: 33) }
    let(:this_case) { Case.create! attributes_for(:case, state_id: state.id) }
    let(:mail) { CaseMailer.send_followers_email(users: [follower], this_case: this_case) }

    before do
      user.follow(this_case)
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

    it 'includes user.name' do
      expect(mail.body.encoded).to match(author.name)
    end
  end
end

RSpec.describe CaseMailer, type: :mailer do
  describe 'notify_of_removal' do
    let(:follower) { FactoryBot.create(:user, name: 'A Follower', email: 'follower@ebwiki.org') }
    let(:this_case) { FactoryBot.create(:case) }
    let(:mail) { CaseMailer.send_deletion_email(users: [follower], this_case: this_case) }

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
end
