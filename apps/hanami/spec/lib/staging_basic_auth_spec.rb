# frozen_string_literal: true

require "eb_wiki/staging_basic_auth"
require "rack/test"

RSpec.describe EbWiki::StagingBasicAuth do
  include Rack::Test::Methods

  let(:inner) { ->(_env) { [200, {"content-type" => "text/plain"}, ["inner"]] } }
  let(:app) { described_class.new(inner) }

  def with_basic_auth(user, password)
    previous_user = ENV["HTTP_BASIC_AUTH_USER"]
    previous_password = ENV["HTTP_BASIC_AUTH_PASSWORD"]
    ENV["HTTP_BASIC_AUTH_USER"] = user
    ENV["HTTP_BASIC_AUTH_PASSWORD"] = password
    yield
  ensure
    ENV["HTTP_BASIC_AUTH_USER"] = previous_user
    ENV["HTTP_BASIC_AUTH_PASSWORD"] = previous_password
  end

  it "passes requests through when credentials are unset" do
    get "/"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("inner")
  end

  it "challenges unauthenticated requests when credentials are set" do
    with_basic_auth("notyet", "suckers") do
      get "/"

      expect(last_response.status).to eq(401)
      expect(last_response.headers["WWW-Authenticate"]).to include("Basic")
      expect(last_response.body).not_to eq("inner")
    end
  end

  it "lets matching credentials through" do
    with_basic_auth("notyet", "suckers") do
      basic_authorize "notyet", "suckers"
      get "/"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("inner")
    end
  end

  it "rejects the wrong password" do
    with_basic_auth("notyet", "suckers") do
      basic_authorize "notyet", "wrong"
      get "/"

      expect(last_response.status).to eq(401)
    end
  end

  it "keeps /up open for Railway healthchecks" do
    with_basic_auth("notyet", "suckers") do
      get "/up"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("ok")
    end
  end
end
