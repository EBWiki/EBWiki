# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Conversations', type: :request do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

  before { allow_any_instance_of(Mailboxer::MailDispatcher).to receive(:call) }

  let!(:conversation) { another_user.send_message(user, Faker::Lorem.paragraph, Faker::Lorem.sentence).conversation }

  describe 'GET /conversations/new' do
    context 'when authenticated' do
      before do
        sign_in user
        get '/conversations/new'
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the list of other users' do
        expect(response.body).to include(another_user.name)
        expect(response.body).not_to include(user.name)
      end
    end

    context 'when not authenticated' do
      before { get '/conversations/new' }

      it 'will return a redirect to the login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST /conversations' do
    context 'when authenticated' do
      let!(:conversation_params) do
        {
          subject: Faker::Lorem.paragraph,
          body: Faker::Lorem.sentence,
          recipients: [another_user.id]
        }
      end

      before do
        sign_in user
        post '/conversations', params: { conversation: conversation_params }
      end

      it 'will create a new conversation' do
        expect(Mailboxer::Conversation.inbox(another_user).count).to eq 1
      end

      it 'will return a redirect to the conversation page' do
        expect(response).to redirect_to conversation_path(Mailboxer::Conversation.inbox(another_user).last)
      end
    end

    context 'when not authenticated' do
      before { post '/conversations' }

      it 'will return a redirect to the login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'GET /conversations/:id' do
    context 'when authenticated' do
      before do
        sign_in user
        get "/conversations/#{conversation.id}"
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the conversation' do
        expect(response.body).to include(conversation.subject)
      end
    end

    context 'when not authenticated' do
      before { get "/conversations/#{conversation.id}" }

      it 'will return a redirect to the login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST /conversations/:id/reply' do
    context 'when authenticated' do
      before do
        sign_in user
        post "/conversations/#{conversation.id}/reply", params: { message: { body: Faker::Lorem.sentence } }
      end

      it 'will reply to conversation' do
        expect(conversation.count_messages).to eq 2
      end

      it 'will return a redirect to the conversation page' do
        expect(response).to redirect_to conversation_path(conversation)
      end
    end

    context 'when not authenticated' do
      before { post "/conversations/#{conversation.id}/reply" }

      it 'will return a redirect to the login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST /conversations/:id/trash' do
    context 'when authenticated' do
      before do
        sign_in user
        post "/conversations/#{conversation.id}/trash"
      end

      it 'will trash the conversation' do
        expect(conversation.is_trashed?(user)).to eq true
      end

      it 'will return a redirect to the mailbox inbox page' do
        expect(response).to redirect_to mailbox_inbox_path
      end
    end

    context 'when not authenticated' do
      before { post "/conversations/#{conversation.id}/trash" }

      it 'will return a redirect to the login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST /conversations/:id/untrash' do
    context 'when authenticated' do
      before do
        conversation.move_to_trash(user)
        sign_in user
        post "/conversations/#{conversation.id}/untrash"
      end

      it 'will untrash the conversation' do
        expect(conversation.is_trashed?(user)).to eq false
      end

      it 'will return a redirect to the mailbox inbox page' do
        expect(response).to redirect_to mailbox_inbox_path
      end
    end

    context 'when not authenticated' do
      before { post "/conversations/#{conversation.id}/untrash" }

      it 'will return a redirect to the login page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
