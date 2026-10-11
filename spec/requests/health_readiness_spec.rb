# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health readiness check', type: :request do
  let(:redis_connection) { instance_double(Redis, ping: 'PONG') }

  around do |example|
    original_elasticsearch = ENV.fetch('ELASTICSEARCH_URL', nil)
    original_searchbox = ENV.fetch('SEARCHBOX_URL', nil)
    example.run
  ensure
    restore_env('ELASTICSEARCH_URL', original_elasticsearch)
    restore_env('SEARCHBOX_URL', original_searchbox)
  end

  before do
    ENV['ELASTICSEARCH_URL'] = 'http://localhost:9200'
    ENV.delete('SEARCHBOX_URL')
    allow(Searchkick.client).to receive(:ping).and_return(true)
    allow($redis).to receive(:with).and_yield(redis_connection)
  end

  describe 'GET /health' do
    it 'returns 200 with all dependency checks when services are up' do
      get '/health'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['status']).to eq('ok')
      %w[postgres redis elasticsearch].each do |name|
        expect(body['checks'][name]['status']).to eq('ok')
        expect(body['checks'][name]['latency_ms']).to be_a(Integer)
      end
    end

    it 'returns 200 with elasticsearch skipped when search URLs are not configured' do
      ENV.delete('ELASTICSEARCH_URL')
      ENV.delete('SEARCHBOX_URL')
      expect(Searchkick.client).not_to receive(:ping)

      get '/health'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['status']).to eq('ok')
      expect(body['checks']['postgres']['status']).to eq('ok')
      expect(body['checks']['redis']['status']).to eq('ok')
      expect(body['checks']['elasticsearch']).to eq('status' => 'skipped')
    end

    it 'returns 503 when Postgres is unreachable' do
      allow(ActiveRecord::Base.connection).to receive(:select_value)
        .and_raise(ActiveRecord::ConnectionNotEstablished, 'connection refused')

      get '/health'

      expect(response).to have_http_status(:service_unavailable)
      body = response.parsed_body
      expect(body['status']).to eq('down')
      expect(body['checks']['postgres']['status']).to eq('down')
      expect(body.to_s).not_to include('connection refused')
    end

    it 'returns 503 when Redis is unreachable' do
      allow($redis).to receive(:with).and_raise(Redis::CannotConnectError, 'no redis')

      get '/health'

      expect(response).to have_http_status(:service_unavailable)
      body = response.parsed_body
      expect(body['status']).to eq('down')
      expect(body['checks']['redis']['status']).to eq('down')
      expect(body.to_s).not_to include('no redis')
    end

    it 'returns 503 when Elasticsearch is configured but unreachable' do
      allow(Searchkick.client).to receive(:ping)
        .and_raise(Faraday::ConnectionFailed.new('no es'))

      get '/health'

      expect(response).to have_http_status(:service_unavailable)
      body = response.parsed_body
      expect(body['status']).to eq('down')
      expect(body['checks']['elasticsearch']['status']).to eq('down')
      expect(body.to_s).not_to include('no es')
    end

    it 'returns 200 when search is configured via SEARCHBOX_URL and elasticsearch responds' do
      ENV.delete('ELASTICSEARCH_URL')
      ENV['SEARCHBOX_URL'] = 'http://searchbox.example:9200'

      get '/health'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['status']).to eq('ok')
      expect(body['checks']['elasticsearch']['status']).to eq('ok')
    end

    it 'includes deploy_rev when DEPLOY_REV is set' do
      original = ENV.fetch('DEPLOY_REV', nil)
      ENV['DEPLOY_REV'] = 'abc123def456'
      get '/health'

      expect(response.parsed_body['deploy_rev']).to eq('abc123def456')
    ensure
      if original.nil?
        ENV.delete('DEPLOY_REV')
      else
        ENV['DEPLOY_REV'] = original
      end
    end
  end

  def restore_env(key, value)
    if value.nil?
      ENV.delete(key)
    else
      ENV[key] = value
    end
  end
end
