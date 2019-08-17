# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminMailer, type: :mailer do
  describe 'admin mailer' do
    let(:user) { FactoryBot.create(:user, admin: true) }
    let(:admin) { FactoryBot.create(:user, name: 'A Follower', email: 'admin@ebwiki.org', admin: true) }
    let!(:mail) { AdminMailer.new_admin_email(new_admin: user, recipients: [admin.email]) }

    it 'renders the subject and receiver email' do
      expect(mail.subject).to eql('A new admin has been added.')
      expect(mail.to).to eq([admin.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['EndBiasWiki@gmail.com'])
    end
  end
end
