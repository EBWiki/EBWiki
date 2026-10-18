# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::SmokeCheck do
  let(:base_url) { 'https://user:secret@staging.example.com' }
  let(:http_client) { instance_double(Release::HttpClient) }
  let(:error_reporter) { class_double(Release::ErrorReporter, report: nil) }
  let(:logger) { instance_double(Logger, info: nil) }

  def response(status:, body: '{}')
    Release::HttpClient::Response.new(status: status, body: body, headers: {})
  end

  subject(:check) do
    described_class.new(
      base_url: base_url,
      http_client: http_client,
      search_term: 'police',
      logger: logger,
      error_reporter: error_reporter
    )
  end

  before do
    allow(http_client).to receive(:get).with('https://user:secret@staging.example.com/').and_return(
      response(status: 200, body: 'home')
    )
    allow(http_client).to receive(:get).with('https://user:secret@staging.example.com/search?query=police').and_return(
      response(status: 200, body: 'Your search for "police" has returned 2 results.')
    )
    allow(http_client).to receive(:get).with(
      "https://user:secret@staging.example.com/search?query=#{CGI.escape(described_class::JUNK_SEARCH_TERM)}"
    ).and_return(
      response(status: 200, body: 'Your search for "ebwiki_smoke_check_no_results_xyz" has returned 0 results.')
    )
    allow(http_client).to receive(:get).with('https://user:secret@staging.example.com/health').and_return(
      response(
        status: 200,
        body: {
          status: 'ok',
          checks: {
            postgres: { status: 'ok', latency_ms: 1 },
            redis: { status: 'ok', latency_ms: 1 }
          }
        }.to_json
      )
    )
  end

  it 'returns true when every step succeeds' do
    expect(check.call).to be(true)
    expect(error_reporter).not_to have_received(:report)
  end

  it 'returns false and reports when the home page fails' do
    allow(http_client).to receive(:get).with('https://user:secret@staging.example.com/').and_return(
      response(status: 503, body: '')
    )

    expect(check.call).to be(false)
    expect(error_reporter).to have_received(:report).with(
      hash_including(event: 'release_smoke_check_failed', context: hash_including(step: :home_page))
    )
  end

  it 'returns false when known search returns zero results' do
    allow(http_client).to receive(:get).with('https://user:secret@staging.example.com/search?query=police').and_return(
      response(status: 200, body: 'Your search for "police" has returned 0 results.')
    )

    expect(check.call).to be(false)
    expect(error_reporter).to have_received(:report).with(
      hash_including(context: hash_including(step: :known_search))
    )
  end

  it 'returns false when junk search does not report zero results' do
    allow(http_client).to receive(:get).with(
      "https://user:secret@staging.example.com/search?query=#{CGI.escape(described_class::JUNK_SEARCH_TERM)}"
    ).and_return(response(status: 200, body: 'error'))

    expect(check.call).to be(false)
    expect(error_reporter).to have_received(:report).with(
      hash_including(context: hash_including(step: :empty_search))
    )
  end

  it 'returns false when health still lists Elasticsearch' do
    allow(http_client).to receive(:get).with('https://user:secret@staging.example.com/health').and_return(
      response(
        status: 200,
        body: { checks: { postgres: {}, redis: {}, elasticsearch: { status: 'skipped' } } }.to_json
      )
    )

    expect(check.call).to be(false)
    expect(error_reporter).to have_received(:report).with(
      hash_including(context: hash_including(step: :postgres_search_path))
    )
  end

  it 'returns false when /health is not JSON' do
    allow(http_client).to receive(:get).with('https://user:secret@staging.example.com/health').and_return(
      response(status: 200, body: 'not-json')
    )

    expect(check.call).to be(false)
    expect(error_reporter).to have_received(:report).with(
      hash_including(context: hash_including(step: :postgres_search_path))
    )
  end

  it 'returns false on network errors' do
    allow(http_client).to receive(:get).with('https://user:secret@staging.example.com/').and_raise(
      SocketError, 'connection refused'
    )

    expect(check.call).to be(false)
    expect(error_reporter).to have_received(:report).with(
      hash_including(context: hash_including(step: :home_page))
    )
  end
end
