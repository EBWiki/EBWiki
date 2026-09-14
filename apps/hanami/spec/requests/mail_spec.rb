# frozen_string_literal: true

RSpec.describe "Outgoing mail", :db, type: :request do
  it "emails a confirmation link after register" do
    post "/register", name: "New Editor", email: "new@example.com", password: "password123"
    expect(last_response.status).to eq(302)
    expect(last_response.headers["Location"]).to eq("/login?registered=1")

    user = TestData.relations[:users].where(email: "new@example.com").one
    mail = EbWiki::Mailer.deliveries.last
    expect(mail.to).to eq("new@example.com")
    expect(mail.subject).to eq("Confirmation instructions")
    expect(mail.html).to include(user[:confirmation_token])

    get "/login?registered=1"
    expect(last_response.body).to include("Check your email for a confirmation link")
  end

  it "emails a reset link without leaking whether the address exists" do
    TestData.insert_user(email: "editor@example.com", password: "password123")

    post "/password", email: "missing@example.com"
    expect(last_response.status).to eq(302)
    expect(EbWiki::Mailer.deliveries).to be_empty

    post "/password", email: "editor@example.com"
    token = TestData.relations[:users].where(email: "editor@example.com").one[:reset_password_token]
    mail = EbWiki::Mailer.deliveries.last
    expect(mail.to).to eq("editor@example.com")
    expect(mail.subject).to eq("Reset password instructions")
    expect(mail.html).to include(token)

    get last_response.headers["Location"]
    expect(last_response.body).to include("If that email is registered")
  end

  it "emails followers when a case is updated and when it is deleted" do
    state_id = TestData.insert_state
    TestData.insert_case(state_id: state_id)
    TestData.insert_subject(case_id: TestData.relations[:cases].where(slug: "walter-scott").one[:id])
    TestData.insert_user(email: "editor@example.com", password: "password123", name: "John")
    TestData.insert_user(email: "follower@ebwiki.org", password: "password123", name: "A Follower")

    post "/login", email: "follower@ebwiki.org", password: "password123"
    post "/cases/walter-scott/follows"
    post "/logout"

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
    update_mail = EbWiki::Mailer.deliveries.find { |mail| mail.subject.include?("updated") }
    expect(update_mail.to).to eq("follower@ebwiki.org")
    expect(update_mail.subject).to eq("The Walter Scott case has been updated on EBWiki.")
    expect(update_mail.html).to include("John")
    expect(update_mail.html).to include("Moved the city name")
    expect(update_mail.html).to include("/cases/walter-scott")

    TestData.insert_user(email: "admin@example.com", password: "password123", admin: true)
    post "/login", email: "admin@example.com", password: "password123"
    post "/cases/walter-scott/delete"

    expect(last_response.status).to eq(302)
    deletion = EbWiki::Mailer.deliveries.find { |mail| mail.subject.include?("removed") }
    expect(deletion.to).to eq("follower@ebwiki.org")
    expect(deletion.subject).to eq("The Walter Scott case has been removed from EBWiki")
  end
end
