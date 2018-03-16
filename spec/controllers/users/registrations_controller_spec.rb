# frozen_string_literal: true

require 'rails_helper'

describe Users::RegistrationsController, '#create', type: :controller do
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end
  describe 'on success' do
    before :each do
      @attr = { email: 'user@example.com',
                password: 'foobar01', password_confirmation: 'foobar01', name: 'johnny' }
    end

    it 'should create a user if the gotcha is answered correctly' do
      Gotcha.skip_validation = true
      expect do
        post :create, user: @attr

        expect(response).to redirect_to(user_path(User.last))
      end.to change { User.count }.by(1)
    end
  end

  describe 'on failure' do
    before :each do
      @attr = { email: 'user@example.com',
                password: 'foobar01', password_confirmation: 'foobar01' }
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'should not create a user if the gotcha is answered correctly' do
      Gotcha.skip_validation = false
      expect do
        post :create, user: @attr
        expect(response).to redirect_to('/users/sign_up')
      end.not_to(change { User.count })
    end
  end
end
