# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mailbox', type: :request do
  let!(:user) { create(:user) }
  let!(:another_user) { create(:user) }

  before { allow_any_instance_of(Mailboxer::MailDispatcher).to receive(:call) }

  let!(:inbox_message) { another_user.send_message(user, Faker::Lorem.paragraph, Faker::Lorem.sentence).message }
  let!(:sent_message) { user.send_message(another_user, Faker::Lorem.paragraph, Faker::Lorem.sentence).message }

  describe 'GET /mailbox' do
    before { get '/mailbox', params: {}, headers: {} }

    it 'will return a redirect to the mailbox inbox page' do
      expect(response).to redirect_to mailbox_inbox_path
    end
  end

  describe 'GET /mailbox/inbox' do
    context 'when authenticated' do
      before do
        sign_in user
        get '/mailbox/inbox', params: {}, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the list of inbox messages' do
        expect(response.body).to include(inbox_message.subject)
        expect(response.body).not_to include(sent_message.subject)
      end
    end

    context 'when not authenticated' do
      before { get '/mailbox/inbox', params: {}, headers: {} }

      it 'will return a redirect to the login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'GET /mailbox/sent' do
    context 'when authenticated' do
      before do
        sign_in user
        get '/mailbox/sent', params: {}, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the list of sent messages' do
        expect(response.body).to include(sent_message.subject)
        expect(response.body).not_to include(inbox_message.subject)
      end
    end

    context 'when not authenticated' do
      before { get '/mailbox/sent', params: {}, headers: {} }

      it 'will return a redirect to the login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'GET /mailbox/trash' do
    context 'when authenticated' do
      before do
        inbox_message.conversation.move_to_trash(user)
        sign_in user
        get '/mailbox/trash', params: {}, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the list of trash messages' do
        expect(response.body).to include(inbox_message.subject)
        expect(response.body).not_to include(sent_message.subject)
      end
    end

    context 'when not authenticated' do
      before { get '/mailbox/trash', params: {}, headers: {} }

      it 'will return a redirect to the login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
