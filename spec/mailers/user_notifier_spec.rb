# frozen_string_literal: true

require 'rails_helper'
PaperTrail.enabled = false
RSpec.describe UserNotifier, type: :mailer do
  describe 'send_followers_email' do
    let(:follower) { mock_model User, name: 'A Follower', email: 'follower@ebwiki.org' }
    let(:author) { mock_model User, name: 'John', email: 'john@email.com' }
    let(:article) { mock_model Article, title: 'John Smith', content: 'some content', state_id: 33 }
    let(:mail) { UserNotifier.send_followers_email([follower], article) }

    before do
      allow(article).to receive_message_chain('versions.last.whodunnit').and_return(User.last)
      allow(article).to receive_message_chain('versions.last.comment').and_return('Comment')
      allow(Rails.logger).to receive(:info)
      allow(User).to receive(:find).and_return(author)
    end

    it 'renders the subject' do
      expect(mail.subject).to eql("The #{article.title} case has been updated on EBWiki.")
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
