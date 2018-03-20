# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConversationsController, type: :controller do
  describe 'GET #new' do
    login_user
    it 'should be successful' do
      get :new
      response.should be_success
    end

    it 'should have a current_user' do
      # note the fact that you should remove the "validate_session" parameter if this was a scaffold-generated controller
      expect(subject.current_user).to_not eq(nil)
    end

    it 'assigns a all other users to @other_users array' do
      get :new
      expect(assigns((:other_users)).class).to eq(Array)
    end

    it 'assigns a all other users to @other_users' do
      get :new
      expect(assigns(:other_users)).not_to include(subject.current_user)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template('new')
    end
  end
end
