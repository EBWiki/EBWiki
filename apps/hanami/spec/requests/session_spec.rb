# frozen_string_literal: true

require "eb_wiki/rails_session"

RSpec.describe "Shared Rails session", :db, type: :request do
  def cookie_header
    Array(last_response.headers["Set-Cookie"] || last_response.headers["set-cookie"]).join("\n")
  end

  it "writes _eb_wiki_session and a Devise Marshal row on login" do
    user_id = TestData.insert_user(email: "editor@example.com", password: "password123", name: "Editor")

    post "/login", email: "editor@example.com", password: "password123"
    expect(last_response.status).to eq(302)
    expect(cookie_header).to include("#{EbWiki::RailsSession::COOKIE}=")

    row = TestData.relations[:sessions].to_a.last
    expect(row).not_to be_nil
    expect(row[:session_id]).to start_with("2::")
    expect(EbWiki::RailsSession.user_id_from_data(row[:data])).to eq(user_id)

    get "/"
    expect(last_response.body).to include("Editor")
    expect(last_response.body).to include("Logout")
  end

  it "treats a Rails cookie plus sessions row as signed in without Hanami session[:user_id]" do
    user_id = TestData.insert_user(email: "editor@example.com", password: "password123", name: "Cookie User")
    public_id = TestData.insert_session(user_id: user_id)

    clear_cookies
    set_cookie("#{EbWiki::RailsSession::COOKIE}=#{public_id}")

    get "/"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Cookie User")
    expect(last_response.body).to include("Logout")
  end

  it "accepts a legacy public session_id stored in the table" do
    user_id = TestData.insert_user(email: "editor@example.com", password: "password123", name: "Legacy")
    user = TestData.relations[:users].where(id: user_id).one
    public_id = SecureRandom.hex(16)
    TestData.relations[:sessions].insert(
      session_id: public_id,
      data: EbWiki::RailsSession.payload_for(user_id, user[:encrypted_password]),
      created_at: Time.now.utc,
      updated_at: Time.now.utc
    )

    clear_cookies
    set_cookie("#{EbWiki::RailsSession::COOKIE}=#{public_id}")

    get "/"
    expect(last_response.body).to include("Legacy")
  end

  it "rejects a session whose Devise salt no longer matches" do
    user_id = TestData.insert_user(email: "editor@example.com", password: "password123", name: "Stale")
    public_id = TestData.insert_session(
      user_id: user_id,
      encrypted_password: "$2a$12$#{"z" * 53}"
    )

    clear_cookies
    set_cookie("#{EbWiki::RailsSession::COOKIE}=#{public_id}")

    get "/"
    expect(last_response.body).to include("Login")
    expect(last_response.body).not_to include("Stale")
  end

  it "clears the Rails session cookie and row on logout" do
    TestData.insert_user(email: "editor@example.com", password: "password123", name: "Editor")

    post "/login", email: "editor@example.com", password: "password123"
    expect(TestData.relations[:sessions].to_a).not_to be_empty

    post "/logout"
    expect(last_response.status).to eq(302)
    expect(TestData.relations[:sessions].to_a).to be_empty

    get "/"
    expect(last_response.body).to include("Login")
    expect(last_response.body).not_to include(">Editor<")
  end
end
