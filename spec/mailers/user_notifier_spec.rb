require "rails_helper"
PaperTrail.enabled = false
RSpec.describe UserNotifier, type: :mailer do
  describe 'welcome_email' do
    let(:user) { mock_model User, name: 'John', email: 'john@email.com', all_following: [User.new] }
    let(:user_with_no_follows) { mock_model User, name: 'Jane', email: 'jane@email.com', all_following: [] }
    let(:mail) { UserNotifier.welcome_email(user) }
    let(:mail_with_no_follows) { UserNotifier.welcome_email(user_with_no_follows) }
 
    it 'renders the subject' do
      expect(mail.subject).to eql('Welcome to EndBiasWiki')
    end
    
    it 'renders the receiver email' do
      expect(mail.to).to eql([user.email])
    end
    
    it 'renders proper message when user has followed 1 or more cases' do
      expect(mail.body.encoded).to include('You have already taken the first step by following 1 case on EBWiki')
      expect(mail_with_no_follows.body.encoded).not_to include('You have already taken the first step by following 1 case on EBWiki')
    end
    
    it 'renders a cta when user has not followed any cases' do
      expect(mail_with_no_follows.body.encoded).to include('It is very important that you click to follow one or more cases')
      expect(mail.body.encoded).not_to include('It is very important that you click to follow one or more cases')
    end
  end
  
  describe 'send_update_email' do
    let(:user) { mock_model User, name: 'John', email: 'john@email.com', all_following: [User.new] }
    let(:article) {mock_model Article, title: 'John Smith', content: 'some content', state_id: 33}
    let(:mail) { UserNotifier.send_update_email(user,article) }
 
    it 'renders the subject' do
      expect(mail.subject).to eql('A new post has been added to EBWiki')
    end
 
    it 'renders the receiver email' do
      expect(mail.to).to eql([user.email])
    end
 
    it 'renders the sender email' do
      expect(mail.from).to eql(['EndBiasWiki@gmail.com'])
    end
 
    it 'includes @title' do
      expect(mail.body.encoded).to match(article.title)
    end
  end
  

  describe 'send_followers_email' do
    let(:follower) { mock_model User, name: 'A Follower', email: 'follower@ebwiki.org' }
    let(:author) { mock_model User, name: 'John', email: 'john@email.com' }
    let(:article) {mock_model Article, title: 'John Smith', content: 'some content', state_id: 33}
    let(:mail) { UserNotifier.send_followers_email([follower],article) }
    
    before do
      allow(article).to receive_message_chain("versions.last.whodunnit").and_return(User.last)
      allow(article).to receive_message_chain("versions.last.comment").and_return("Comment")
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
