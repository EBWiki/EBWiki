# frozen_string_literal: true

RSpec.describe "Friendly photos", :db, type: :request do
  around do |example|
    previous = ENV["E2E_STUB_WIKIMEDIA"]
    ENV["E2E_STUB_WIKIMEDIA"] = "1"
    example.run
  ensure
    ENV["E2E_STUB_WIKIMEDIA"] = previous
  end

  it "lists cases so editors start from a person's name" do
    state_id = TestData.insert_state
    case_id = TestData.insert_case(state_id: state_id)
    TestData.insert_subject(case_id: case_id)

    get "/friendly_photos"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Friendly photos")
    expect(last_response.body).to include("Walter Scott")
    expect(last_response.body).to include("/friendly_photos/walter-scott")
  end

  it "searches locked sources and flags likely mugshots" do
    state_id = TestData.insert_state
    case_id = TestData.insert_case(state_id: state_id)
    TestData.insert_subject(case_id: case_id)

    get "/friendly_photos/walter-scott"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Photos for Walter Scott")
    expect(last_response.body).to include("E2E family portrait")
    expect(last_response.body).to include("E2E openverse portrait")
    expect(last_response.body).to include("Likely mugshot or booking photo")
    expect(last_response.body).not_to include("arrests.org")
  end

  it "returns 404 for an unknown slug" do
    get "/friendly_photos/missing"

    expect(last_response.status).to eq(404)
  end

  it "attaches an allowed portrait when a signed-in editor applies it" do
    state_id = TestData.insert_state
    case_id = TestData.insert_case(state_id: state_id)
    TestData.insert_subject(case_id: case_id)
    TestData.insert_user(email: "editor@example.com", password: "password123")

    post "/login", email: "editor@example.com", password: "password123"

    portrait_url = "https://upload.wikimedia.org/wikipedia/commons/a/ab/e2e-portrait.jpg"
    post "/friendly_photos/walter-scott/attach",
      source: "wikimedia_commons",
      title: "E2E family portrait",
      image_url: portrait_url,
      page_url: "https://commons.wikimedia.org/wiki/File:E2E_family_portrait.jpg",
      license: "CC BY-SA 4.0",
      author: "E2E fixture",
      description: "Family photo portrait",
      likely_mugshot: "0"

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_response.body).to include("Applied the selected profile picture")

    stored = TestData.relations[:cases].where(id: case_id).one
    expect(stored[:default_avatar_url]).to eq(portrait_url)
  end

  it "refuses a mugshot attach and leaves the case unchanged" do
    state_id = TestData.insert_state
    case_id = TestData.insert_case(state_id: state_id)
    TestData.insert_subject(case_id: case_id)
    TestData.insert_user(email: "editor@example.com", password: "password123")

    post "/login", email: "editor@example.com", password: "password123"

    post "/friendly_photos/walter-scott/attach",
      source: "wikimedia_commons",
      title: "E2E institutional photo",
      image_url: "https://upload.wikimedia.org/wikipedia/commons/b/bc/e2e-mugshot.jpg",
      page_url: "https://commons.wikimedia.org/wiki/File:E2E_institutional_photo.jpg",
      license: "Public domain",
      author: "Sheriff",
      description: "County jail booking photo",
      likely_mugshot: "1"

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_response.body).to include("not a healthy profile picture")

    stored = TestData.relations[:cases].where(id: case_id).one
    expect(stored[:default_avatar_url]).to be_nil
  end
end
