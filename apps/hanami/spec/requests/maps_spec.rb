# frozen_string_literal: true

RSpec.describe "Case map", :db, type: :request do
  it "renders geocoded cases as JSON for the Leaflet map" do
    state_id = TestData.insert_state
    TestData.insert_case(state_id: state_id, latitude: 32.8546, longitude: -79.9748)
    TestData.insert_case(
      state_id: state_id,
      title: "No coordinates",
      slug: "no-coordinates",
      city: "Unknown"
    )

    get "/maps"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Case Map")
    expect(last_response.body).to include("id=\"map-container\"")
    expect(last_response.body).to include("walter-scott")
    expect(last_response.body).to include("32.8546")
    expect(last_response.body).not_to include("no-coordinates")
  end
end
