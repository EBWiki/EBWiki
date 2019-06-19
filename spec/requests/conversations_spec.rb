# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Conversations', type: :request do
  # describe 'GET /conversations/new' do
  #   let(:user) { create_list(:user, 5) }

  #   context "will get the form for a conversation" do
  #     before(:each) do
  #       sign_in user[0]
  #       get '/conversations/new', params: {}, headers: {}
  #     end

  #     it 'will return status code 200' do
  #       expect(response).to have_http_status(200)
  #     end

  #     it 'will return the form' do
  #       expect(response.body).to include('New')
  #     end
  #   end
  # end

  describe 'POST /conversations' do
    let(:user_one) { create(:user) }
    let(:user_two) { create(:user) }
    let(:params) { { conversation: attributes_for(:conversation).merge({ recipients: user_two.id }) } }

    context 'when message is sent' do
      before do
        sign_in user_one
        post '/conversations', params: params, headers: {}
      end

      it 'will redirect to the conversation page' do
        expect(response.body).to include(user_two.name)
      end
    end

    context 'when the message has errors' do
      before do
        sign_in user_one
        post '/conversations', params: attributes_for(:conversation), headers: {}
      end

      it 'will redirect back to the form' do
        expect(response.body).to include('New')
      end
    end
  end

  # describe 'GET /conversations/:id' do
  #   let(:user_one) { create(:user) }
  #   let(:user_two) { create(:user) }
  #   let(:convo) { attributes_for(:conversation) }

  #   context 'when retreiving user messages' do
  #     before do
  #       sign_in user_one
  #       message = user_one.send_message(user_two.id, convo[:body], convo[:subject])
  #       get "/conversations/#{message.conversation.id}", params: {}, headers: {}
  #     end

  #     it 'will return status code 200' do
  #       expect(response).to have_http_status(200)
  #     end

  #     it 'will show the conversation' do
  #       expect(response.body).to include('Message')
  #     end
  #   end

  # describe 'POST /conversations/:id/reply' do
  #   let(:user_one) { create(:user) }
  #   let(:user_two) { create(:user) }
  #   let(:convo_one) { attributes_for(:coversation) }
  #   let(:convo_two) { attributes_for(:conversation) }

  #   context 'when replying to a message' do
  #     before do
  #       message = user_one.send_message(user_two.id, convo_one[:body], convo_one[:subject])
  #       sign_in user_two
  #       post "/conversations/#{message.conversation.id}/reply", params: params, headers: {}
  #     end

  #     it 'will return status code 200' do
  #       expect(response).to have_http_status(200)
  #     end

  #     it 'will display the conversation' do
  #       expect(response.body).to include(convo_two[:body])
  #     end
  #   end
  # end

  # describe 'POST /conversations/:id/trash' do
  #   let(:user_one) { create(:user) }
  #   let(:user_two) { create(:user) }
  #   let(:convo) { attributes_for(:conversation) }

  #   context 'when deleting a message' do
  #     before do
  #       sign_in user_one
  #       message = user_one.send_message(user_two.id, convo[:body], convo[:subject] )
  #       post "/conversations/#{message.conversation.id}/trash"
  #     end

  #     it 'will redirect to the inbox' do
  #       expect(response).to redirect_to mailbox_index_path
  #     end
  #   end
  # end

  # describe 'POST /conversations/:id/untrash' do
  #   let(:user_one) { create(:user) }
  #   let(:user_two) { create(:user) }
  #   let(:convo) { attributes_for(:conversation) }

  #   context 'when restoring a deleted message' do
  #     before do
  #       sign_in user_one
  #       message = user_one.send_message(user_two.id, convo[:body], convo[:subject] )
  #       message.conversation.move_to_trash(user_one)
  #       post "/conversations/#{message.conversation.id}/untrash"
  #     end

  #     it 'will redirect to the inbox' do
  #       expect(response).to redirect_to mailbox_index_path
  #     end
  #   end
  # end
end
