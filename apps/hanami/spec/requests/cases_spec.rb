# frozen_string_literal: true

require "yaml"

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

  it "uses the CarrierWave large_avatar object key without changing S3 keys" do
    state_id = TestData.insert_state
    TestData.insert_case(state_id: state_id, avatar: "scott.jpg")

    get "/cases/walter-scott"

    expect(last_response.body).to include("/uploads/case/avatar/")
    expect(last_response.body).to include("large_avatar_scott.jpg")
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
    user_id = TestData.insert_user(name: "History Editor")
    TestData.insert_version(
      case_id: case_id,
      comment: "Corrected city spelling",
      whodunnit: user_id.to_s,
      author_id: user_id
    )

    get "/cases/walter-scott/history"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("History")
    expect(last_response.body).to include("Corrected city spelling")
    expect(last_response.body).to include("History Editor")
  end

  it "serves the about page" do
    get "/about"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Our Mission")
  end

  it "rejects unknown logins and accepts a confirmed Devise-compatible password" do
    TestData.insert_user(email: "editor@example.com", password: "password123")

    post "/login", email: "editor@example.com", password: "wrong"
    expect(last_response.status).to eq(401)

    post "/login", email: "editor@example.com", password: "password123"
    expect(last_response.status).to eq(302)
    expect(last_response.headers["Location"]).to eq("/")
  end

  it "creates a case with a subject, link, agency, and history row" do
    TestData.insert_user(email: "editor@example.com", password: "password123")
    state_id = TestData.insert_state
    agency_id = TestData.insert_agency

    post "/login", email: "editor@example.com", password: "password123"
    post "/cases", {
      case: {
        title: "New Test Case",
        date: "2016-01-02",
        city: "Chicago",
        state_id: state_id,
        overview: "<p>An overview of the case.</p>",
        blurb: "A short blurb",
        summary: "Created the case",
        cause_of_death: "shooting",
        subjects: [{name: "Test Subject", age: "22"}],
        links: [{url: "https://example.com/source", title: "Source"}],
        agency_ids: [agency_id]
      }
    }

    expect(last_response.status).to eq(302)
    expect(last_response.headers["Location"]).to eq("/cases/new-test-case")

    get "/cases/new-test-case"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Test Subject")
    expect(last_response.body).to include("https://example.com/source")
    expect(last_response.body).to include("North Charleston Police Department")

    get "/cases/new-test-case/history"
    expect(last_response.body).to include("Created the case")
  end

  it "updates a case and stores a YAML snapshot for later revert" do
    state_id = TestData.insert_state
    TestData.insert_case(state_id: state_id)
    TestData.insert_subject(case_id: TestData.relations[:cases].where(slug: "walter-scott").one[:id])
    TestData.insert_user(email: "editor@example.com", password: "password123")

    post "/login", email: "editor@example.com", password: "password123"
    post "/cases/walter-scott", {
      _method: "patch",
      case: {
        title: "Walter Scott",
        date: "2015-04-04",
        city: "Charleston",
        state_id: state_id,
        overview: "<p>Updated overview.</p>",
        blurb: "Updated blurb",
        summary: "Moved the city name",
        cause_of_death: "shooting",
        subjects: [{name: "Walter Scott", age: "50"}],
        links: [{url: "", title: ""}],
        agency_ids: []
      }
    }

    expect(last_response.status).to eq(302)
    expect(TestData.relations[:cases].where(slug: "walter-scott").one[:city]).to eq("Charleston")
    version = TestData.relations[:versions].where(item_type: "Case").order(Sequel.desc(:id)).first
    expect(version[:object]).to include("North Charleston")
  end

  it "requires login to follow and comment, then writes both" do
    seed_walter_scott
    TestData.insert_user(email: "editor@example.com", password: "password123")

    post "/cases/walter-scott/comments", content: "hello"
    expect(last_response.status).to eq(302)
    expect(last_response.headers["Location"]).to eq("/login")

    post "/login", email: "editor@example.com", password: "password123"
    post "/cases/walter-scott/comments", content: "Remember the video."
    expect(last_response.status).to eq(302)

    post "/cases/walter-scott/follows"
    get "/cases/walter-scott"
    expect(last_response.body).to include("Remember the video.")
  end

  it "lists organizations" do
    TestData.insert_organization
    get "/organizations"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Color of Change")
  end

  it "lets an admin toggle analyst on another user" do
    TestData.insert_user(email: "admin@example.com", password: "password123", admin: true)
    target_id = TestData.insert_user(email: "writer@example.com", password: "password123", name: "Writer")

    post "/login", email: "admin@example.com", password: "password123"
    post "/admin/users/#{target_id}", admin: "0", analyst: "1"
    expect(last_response.status).to eq(302)

    user = TestData.relations[:users].where(id: target_id).one
    expect(user[:analyst]).to be_truthy
  end

  it "reverts a case from a PaperTrail YAML snapshot without deleting it" do
    state_id = TestData.insert_state
    case_id = TestData.insert_case(state_id: state_id, city: "Charleston")
    version_id = TestData.insert_version(
      case_id: case_id,
      comment: "City before correction",
      object: YAML.dump("city" => "North Charleston", "title" => "Walter Scott", "summary" => "snapshot")
    )
    TestData.insert_user(email: "editor@example.com", password: "password123")

    post "/login", email: "editor@example.com", password: "password123"
    post "/cases/walter-scott/history/#{version_id}/revert"

    expect(last_response.status).to eq(302)
    expect(TestData.relations[:cases].where(id: case_id).one[:city]).to eq("North Charleston")

    get "/cases/walter-scott/history"
    expect(last_response.body).to include("Reverted to version #{version_id}")
  end

  it "does not destroy a case when a create version has no snapshot" do
    case_id = seed_walter_scott
    version_id = TestData.insert_version(case_id: case_id, event: "create", comment: "Initial", object: nil)
    TestData.insert_user(email: "editor@example.com", password: "password123")

    post "/login", email: "editor@example.com", password: "password123"
    post "/cases/walter-scott/history/#{version_id}/revert"

    expect(last_response.status).to eq(302)
    expect(TestData.relations[:cases].where(id: case_id).one).not_to be_nil
  end

  it "creates an agency and organization, then lets an admin edit the organization" do
    TestData.insert_user(email: "admin@example.com", password: "password123", admin: true)
    state_id = TestData.insert_state

    post "/login", email: "admin@example.com", password: "password123"
    post "/agencies", {
      agency: {
        name: "Chicago Police Department",
        city: "Chicago",
        state_id: state_id,
        jurisdiction: "local"
      }
    }
    expect(last_response.status).to eq(302)
    expect(last_response.headers["Location"]).to eq("/agencies/chicago-police-department")

    post "/organizations", {organization: {name: "Black Lives Matter", website: "https://blacklivesmatter.com"}}
    expect(last_response.status).to eq(302)
    org_id = TestData.relations[:organizations].where(name: "Black Lives Matter").one[:id]

    post "/organizations/#{org_id}", {_method: "patch", organization: {name: "Black Lives Matter", description: "National"}}
    expect(last_response.status).to eq(302)
    expect(TestData.relations[:organizations].where(id: org_id).one[:description]).to eq("National")
  end

  it "registers, confirms with the Devise token path, and shows a profile" do
    post "/register", name: "New Editor", email: "new@example.com", password: "password123"
    expect(last_response.status).to eq(302)

    user = TestData.relations[:users].where(email: "new@example.com").one
    expect(user[:confirmed_at]).to be_nil

    get "/users/confirmation", confirmation_token: user[:confirmation_token]
    expect(last_response.status).to eq(302)

    get "/users/#{user[:id]}"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("New Editor")
  end

  it "lets the author delete a comment and embeds a map when coordinates exist" do
    state_id = TestData.insert_state
    TestData.insert_case(state_id: state_id, latitude: 32.8546, longitude: -79.9748)
    user_id = TestData.insert_user(email: "editor@example.com", password: "password123")

    post "/login", email: "editor@example.com", password: "password123"
    post "/cases/walter-scott/comments", content: "Please remove this."
    comment = TestData.relations[:comments].where(user_id: user_id).one

    get "/cases/walter-scott"
    expect(last_response.body).to include("openstreetmap.org")
    expect(last_response.body).to include("Please remove this.")

    post "/comments/#{comment[:id]}/delete"
    expect(last_response.status).to eq(302)
    expect(TestData.relations[:comments].where(id: comment[:id]).one).to be_nil
  end

  it "rejects a duplicate agency name and forbids non-admins from editing an organization" do
    state_id = TestData.insert_state
    TestData.insert_agency(name: "Chicago Police Department", slug: "cpd")
    org_id = TestData.insert_organization
    TestData.insert_user(email: "editor@example.com", password: "password123")

    post "/login", email: "editor@example.com", password: "password123"
    post "/agencies", {agency: {name: "Chicago Police Department", city: "Chicago", state_id: state_id}}
    expect(last_response.status).to eq(422)
    expect(last_response.body).to include("already exists")

    get "/organizations/#{org_id}/edit"
    expect(last_response.status).to eq(403)
  end

  it "lets a user edit their profile and lists followed cases there" do
    seed_walter_scott
    user_id = TestData.insert_user(email: "editor@example.com", password: "password123", name: "Editor")

    post "/login", email: "editor@example.com", password: "password123"
    post "/cases/walter-scott/follows"
    post "/users/#{user_id}", {_method: "patch", user: {name: "Editor Two", description: "Writes about cases"}}

    expect(last_response.status).to eq(302)
    get "/users/#{user_id}"
    expect(last_response.body).to include("Editor Two")
    expect(last_response.body).to include("Writes about cases")
    expect(last_response.body).to include("Walter Scott")
  end

  it "resets a password from a stored Devise token" do
    TestData.insert_user(email: "editor@example.com", password: "password123")

    post "/password", email: "editor@example.com"
    token = TestData.relations[:users].where(email: "editor@example.com").one[:reset_password_token]
    expect(token).not_to be_nil

    post "/password/update", reset_password_token: token, password: "newpass123"
    expect(last_response.status).to eq(302)

    post "/login", email: "editor@example.com", password: "password123"
    expect(last_response.status).to eq(401)

    post "/login", email: "editor@example.com", password: "newpass123"
    expect(last_response.status).to eq(302)
  end
end
