# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StagingExposureCheck do
  let(:railway_url) { 'https://ebwiki-web-production-cc7e.up.railway.app' }
  let(:staging_url) { 'https://staging.ebwiki.org' }
  let(:health_path) { described_class::HEALTH_PATH }
  let(:client_id) { 'test-client-id' }
  let(:client_secret) { 'test-client-secret' }

  def response(code:, location: nil, headers: {}, error: nil)
    merged = headers.transform_keys { |key| key.to_s.downcase }
    merged['location'] = location if location
    described_class::Response.new(code: code, headers: merged, error: error)
  end

  def http_stub(&block)
    lambda do |url, **kwargs|
      yield(url, **kwargs)
    end
  end

  def run_check(http)
    described_class.call(
      railway_urls: [railway_url],
      staging_url: staging_url,
      cf_access_client_id: client_id,
      cf_access_client_secret: client_secret,
      http: http
    )
  end

  describe '.resolve_railway_urls' do
    it 'uses argv when present' do
      urls = described_class.resolve_railway_urls(
        argv: ['https://example.railway.app'],
        env_railway_urls: ',,,'
      )
      expect(urls).to eq(['https://example.railway.app'])
    end

    it 'fails when STAGING_EXPOSURE_RAILWAY_URLS is set but empty' do
      expect do
        described_class.resolve_railway_urls(argv: [], env_railway_urls: ' , , ')
      end.to raise_error(described_class::CheckFailed, /contains no URLs/)
    end

    it 'falls back to the default URL when the env var is unset' do
      urls = described_class.resolve_railway_urls(argv: [], env_railway_urls: nil)
      expect(urls).to eq([described_class::DEFAULT_RAILWAY_URL])
    end
  end

  describe '.call' do
    context 'when every check passes' do
      it 'accepts a railway URL that does not answer' do
        http = http_stub do |url, **_kwargs|
          case url
          when railway_url then response(code: nil, error: StandardError.new('connection refused'))
          when "#{staging_url}/" then response(code: 302, location: 'https://ebwiki.cloudflareaccess.com/cdn-cgi/access/login')
          when "#{staging_url}#{health_path}" then response(code: 200)
          else raise "unexpected url #{url}"
          end
        end

        expect { run_check(http) }.not_to raise_error
      end

      it 'accepts a railway URL that returns 404' do
        http = http_stub do |url, **_kwargs|
          case url
          when railway_url then response(code: '404')
          when "#{staging_url}/" then response(code: 403, headers: { 'cf-middleware-access' => '1' })
          when "#{staging_url}#{health_path}" then response(code: 200)
          else raise "unexpected url #{url}"
          end
        end

        expect { run_check(http) }.not_to raise_error
      end

      it 'accepts staging root with Cloudflare Access response headers' do
        http = http_stub do |url, **_kwargs|
          case url
          when railway_url then response(code: '404')
          when "#{staging_url}/" then response(code: 403, headers: { 'cf-access-authenticated-user-email' => 'user@example.com' })
          when "#{staging_url}#{health_path}" then response(code: 200)
          else raise "unexpected url #{url}"
          end
        end

        expect { run_check(http) }.not_to raise_error
      end
    end

    context 'when railway URLs are still exposed' do
      it 'fails when the railway URL returns 200' do
        http = http_stub { |_url, **_kwargs| response(code: '200') }

        expect { run_check(http) }.to raise_error(
          described_class::CheckFailed,
          /Railway URL still answers/
        )
      end

      it 'fails when the railway URL returns 401' do
        http = http_stub { |_url, **_kwargs| response(code: '401') }

        expect { run_check(http) }.to raise_error(
          described_class::CheckFailed,
          /Railway URL still answers/
        )
      end
    end

    context 'when staging is not gated at the root' do
      it 'fails when the root returns 200' do
        http = http_stub do |url, **_kwargs|
          case url
          when railway_url then response(code: '404')
          when "#{staging_url}/" then response(code: 200)
          else response(code: 200)
          end
        end

        expect { run_check(http) }.to raise_error(
          described_class::CheckFailed,
          /not gated by Cloudflare Access/
        )
      end

      it 'fails when redirect is not to cloudflareaccess.com' do
        http = http_stub do |url, **_kwargs|
          case url
          when railway_url then response(code: '404')
          when "#{staging_url}/" then response(code: 302, location: 'https://example.com/login')
          else response(code: 200)
          end
        end

        expect { run_check(http) }.to raise_error(
          described_class::CheckFailed,
          /not gated by Cloudflare Access/
        )
      end

      it 'fails when staging root returns app basic auth without Cloudflare Access' do
        http = http_stub do |url, **_kwargs|
          case url
          when railway_url then response(code: '404')
          when "#{staging_url}/"
            response(
              code: 401,
              headers: { 'www-authenticate' => 'Basic realm="Staging"' }
            )
          else response(code: 200)
          end
        end

        expect { run_check(http) }.to raise_error(
          described_class::CheckFailed,
          /app basic auth.*not Cloudflare Access/
        )
      end

      it 'fails when staging root does not answer' do
        http = http_stub do |url, **_kwargs|
          case url
          when railway_url then response(code: '404')
          when "#{staging_url}/" then response(code: nil, error: StandardError.new('timeout'))
          else response(code: 200)
          end
        end

        expect { run_check(http) }.to raise_error(
          described_class::CheckFailed,
          /Could not reach staging hostname/
        )
      end
    end

    context "when #{described_class::HEALTH_PATH} with service token is wrong" do
      it 'fails when service token env values are missing' do
        http = http_stub do |url, **_kwargs|
          case url
          when railway_url then response(code: '404')
          when "#{staging_url}/" then response(code: 302, location: 'https://ebwiki.cloudflareaccess.com/cdn-cgi/access/login')
          else response(code: 200)
          end
        end

        expect do
          described_class.call(
            railway_urls: [railway_url],
            staging_url: staging_url,
            cf_access_client_id: nil,
            cf_access_client_secret: 'secret',
            http: http
          )
        end.to raise_error(described_class::CheckFailed, /Missing Cloudflare Access service token/)
      end

      it 'passes when the health path returns 200 with token headers' do
        http = http_stub do |url, headers:, **_kwargs|
          case url
          when railway_url then response(code: '404')
          when "#{staging_url}/" then response(code: 302, location: 'https://ebwiki.cloudflareaccess.com/cdn-cgi/access/login')
          when "#{staging_url}#{health_path}"
            expect(headers).to include(
              described_class::CF_ACCESS_CLIENT_ID_HEADER => client_id,
              described_class::CF_ACCESS_CLIENT_SECRET_HEADER => client_secret
            )
            response(code: 200)
          else raise "unexpected url #{url}"
          end
        end

        expect { run_check(http) }.not_to raise_error
      end

      it 'fails when the health path returns 403 with token headers' do
        http = http_stub do |url, headers:, **_kwargs|
          case url
          when railway_url then response(code: '404')
          when "#{staging_url}/" then response(code: 302, location: 'https://ebwiki.cloudflareaccess.com/cdn-cgi/access/login')
          when "#{staging_url}#{health_path}"
            expect(headers).to include(
              described_class::CF_ACCESS_CLIENT_ID_HEADER => client_id,
              described_class::CF_ACCESS_CLIENT_SECRET_HEADER => client_secret
            )
            response(code: 403)
          else raise "unexpected url #{url}"
          end
        end

        expect { run_check(http) }.to raise_error(
          described_class::CheckFailed,
          %r{#{health_path} with service token did not return 200}
        )
      end

      it 'fails when the health path does not answer' do
        http = http_stub do |url, **_kwargs|
          case url
          when railway_url then response(code: '404')
          when "#{staging_url}/" then response(code: 302, location: 'https://ebwiki.cloudflareaccess.com/cdn-cgi/access/login')
          when "#{staging_url}#{health_path}" then response(code: nil, error: StandardError.new('reset'))
          else raise "unexpected url #{url}"
          end
        end

        expect { run_check(http) }.to raise_error(
          described_class::CheckFailed,
          %r{Could not reach .*#{health_path}}
        )
      end
    end
  end

  describe '.cloudflare_access_redirect?' do
    it 'returns true for cloudflareaccess.com locations' do
      resp = response(code: 302, location: 'https://team.cloudflareaccess.com/cdn-cgi/access/login')
      expect(described_class.cloudflare_access_redirect?(resp)).to be true
    end

    it 'returns false for non-redirect responses' do
      expect(described_class.cloudflare_access_redirect?(response(code: 401))).to be false
    end
  end

  describe '.staging_app_basic_auth_only?' do
    it 'returns true for Staging basic-auth 401 responses' do
      resp = response(code: 401, headers: { 'www-authenticate' => 'Basic realm="Staging"' })
      expect(described_class.staging_app_basic_auth_only?(resp)).to be true
    end
  end
end
