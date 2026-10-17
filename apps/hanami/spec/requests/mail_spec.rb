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
    skip "Follower lookup and admin delete mail land in the stacked pull request on this branch."
  end
end
