# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rails health check', type: :request do
  describe 'GET /up' do
    it 'returns 200 when the app is booted' do
      get '/up'

      expect(response).to have_http_status(:ok)
    end

    it 'returns JSON status when requested' do
      get '/up', headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['status']).to eq('up')
      expect(body['timestamp']).to be_present
    end

    it 'includes deploy_rev in JSON when DEPLOY_REV is set' do
      original = ENV.fetch('DEPLOY_REV', nil)
      ENV['DEPLOY_REV'] = 'abc123def456'
      get '/up', headers: { 'Accept' => 'application/json' }

      body = response.parsed_body
      expect(body['deploy_rev']).to eq('abc123def456')
    ensure
      if original.nil?
        ENV.delete('DEPLOY_REV')
      else
        ENV['DEPLOY_REV'] = original
      end
    end
  end
end
