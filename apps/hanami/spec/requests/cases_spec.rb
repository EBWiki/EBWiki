# frozen_string_literal: true

RSpec.describe "Public case pages", :db, type: :request do
  def seed_walter_scott
    state_id = TestData.insert_state
    case_id = TestData.insert_case(state_id: state_id)
    TestData.insert_subject(case_id: case_id)
    agency_id = TestData.insert_agency
    TestData.insert_case_agency(case_id: case_id, agency_id: agency_id)
    TestData.insert_link(case_id: case_id, url: "https://example.com/walter-scott")
    case_id
  end

  it "lists cases on the homepage with the live count" do
    seed_walter_scott
    TestData.insert_case(
      state_id: TestData.relations[:states].first[:id],
      title: "Sandra Bland",
      slug: "sandra-bland",
      city: "Prairie View",
      date: Date.new(2015, 7, 13)
    )

    get "/"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("tracking")
    expect(last_response.body).to include("<span class=\"accent\">2</span>")
    expect(last_response.body).to include("Walter Scott")
    expect(last_response.body).to include("/cases/walter-scott")
    expect(last_response.body).to include("Sandra Bland")
  end

  it "renders a case page from its FriendlyId slug" do
    seed_walter_scott

    get "/cases/walter-scott"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Walter Scott")
    expect(last_response.body).to include("North Charleston")
    expect(last_response.body).to include("South Carolina")
    expect(last_response.body).to include("April 4, 2015")
    expect(last_response.body).to include("Shooting")
    expect(last_response.body).to include("North Charleston Police Department")
    expect(last_response.body).to include("shot in the back")
    expect(last_response.body).to include("https://example.com/walter-scott")
  end

  it "returns 404 for an unknown slug" do
    get "/cases/does-not-exist"

    expect(last_response.status).to eq(404)
  end

  it "keeps the Rails /articles/:slug redirect" do
    get "/articles/walter-scott"

    expect(last_response.status).to eq(301)
    expect(last_response.headers["Location"]).to eq("/cases/walter-scott")
  end

  it "redirects /articles to /cases" do
    get "/articles"

    expect(last_response.status).to eq(301)
    expect(last_response.headers["Location"]).to eq("/cases")
  end

  it "searches cases by title and city" do
    seed_walter_scott
    TestData.insert_case(
      state_id: TestData.relations[:states].first[:id],
      title: "Sandra Bland",
      slug: "sandra-bland",
      city: "Prairie View",
      date: Date.new(2015, 7, 13),
      overview: "<p>Arrested during a traffic stop in Prairie View, Texas.</p>",
      blurb: "Sandra Bland was found dead in a jail cell in Waller County."
    )

    get "/search?query=Charleston"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Walter Scott")
    expect(last_response.body).not_to include("Sandra Bland")
  end

  it "lists agencies and shows one by slug with its cases" do
    seed_walter_scott

    get "/agencies"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("North Charleston Police Department")

    get "/agencies/ncpd"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("North Charleston Police Department")
    expect(last_response.body).to include("Walter Scott")
  end

  it "reads PaperTrail versions for a case history page" do
    case_id = seed_walter_scott
    TestData.insert_version(case_id: case_id, comment: "Corrected city spelling")

    get "/cases/walter-scott/history"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("History")
    expect(last_response.body).to include("Corrected city spelling")
  end

  it "serves the about page" do
    get "/about"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Our Mission")
  end
end

