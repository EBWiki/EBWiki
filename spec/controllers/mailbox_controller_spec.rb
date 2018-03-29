# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MailboxController, type: :controller do
  describe 'GET #inbox' do
    describe 'on success' do
      login_user

      it 'returns the mailbox index page successfully' do
        get :inbox
        expect(response).to have_http_status(:success)
      end
    end

    describe 'on failure' do
      it 'redirects to the signin page' do
        get :inbox
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
RSpec.describe MailboxController, type: :controller do
  describe 'GET #sent' do
    describe 'on success' do
      login_user

      it 'returns the mailbox sent page successfully' do
        get :sent
        expect(response).to have_http_status(:success)
      end
    end

    describe 'on failure' do
      it 'redirects to the signin page' do
        get :sent
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
RSpec.describe MailboxController, type: :controller do
  describe 'GET #trash' do
    describe 'on success' do
      login_user

      it 'returns the mailbox trash page successfully' do
        get :trash
        expect(response).to have_http_status(:success)
      end
    end

    describe 'on failure' do
      it 'redirects to the signin page' do
        get :trash
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
