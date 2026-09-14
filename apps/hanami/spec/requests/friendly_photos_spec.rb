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
end
