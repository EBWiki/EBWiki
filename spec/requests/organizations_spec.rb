# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Organizations', type: :request do
  describe 'GET /organizations' do
    it 'works! (now write some real specs)' do
      get '/organizations'
      expect(response).to have_http_status(200)
    end
  end
end
