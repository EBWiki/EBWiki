# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Maps', type: :request do
  describe 'GET /maps' do
    context 'will get a map with a list of cases marked on it' do
      let(:redis) { MockRedis.new }
      let(:this_case) { create(:case) }

      before do
        redis.set('cases', [this_case].to_json)
        get '/maps', params: {}, headers: {}
      end

      it 'will return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'will return the list of cases' do
        expect(response.body).to include('maps')
      end
    end
  end
end
