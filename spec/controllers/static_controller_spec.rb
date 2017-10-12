# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StaticController, type: :controller do
  describe 'GET #about' do
    it 'returns http success' do
      get :about
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #javascript_lab' do
    describe 'on success' do
      it 'returns success when not in production' do
        get :javascript_lab
        expect(response).to have_http_status(:success)
      end
    end

    describe 'on failure' do
      it 'redirects to the home page when in production' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        get :javascript_lab
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
