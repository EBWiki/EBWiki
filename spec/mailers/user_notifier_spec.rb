require "rails_helper"

RSpec.describe UserNotifier, type: :mailer do
  describe 'send_update_email' do
    let(:user) { mock_model User, name: 'John', email: 'john@email.com' }
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
end
