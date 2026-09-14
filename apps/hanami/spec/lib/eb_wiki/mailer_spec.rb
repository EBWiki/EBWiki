# frozen_string_literal: true

require "eb_wiki/mailer"

RSpec.describe EbWiki::Mailer do
  let(:user) { {email: "editor@example.com", name: "New Editor"} }
  let(:this_case) { {title: "Walter Scott", slug: "walter-scott"} }

  it "records confirmation instructions without sending SMTP in test" do
    described_class.confirmation_instructions(
      user: user,
      token: "abc123",
      base_url: "http://example.test"
    )

    mail = described_class.deliveries.last
    expect(mail.to).to eq("editor@example.com")
    expect(mail.from).to eq("EndBiasWiki@gmail.com")
    expect(mail.subject).to eq("Confirmation instructions")
    expect(mail.html).to include("Welcome New Editor!")
    expect(mail.html).to include("Thanks for signing up for EBWiki")
    expect(mail.html).to include("Click here to confirm your account")
    expect(mail.html).to include("http://example.test/users/confirmation?confirmation_token=abc123")
    expect(described_class.transmit?).to be(false)
  end

  it "records a password reset that uses the Hanami edit path" do
    described_class.reset_password_instructions(
      user: user,
      token: "reset-token",
      base_url: "http://example.test/"
    )

    mail = described_class.deliveries.last
    expect(mail.subject).to eq("Reset password instructions")
    expect(mail.html).to include("Hello editor@example.com!")
    expect(mail.html).to include("http://example.test/password/edit?reset_password_token=reset-token")
  end

  it "sends one follower email per user using the Rails subject" do
    described_class.send_followers_email(
      users: [user, {email: "follower@example.com", name: "A Follower"}],
      this_case: this_case,
      editor_name: "John",
      comment: "Corrected city spelling",
      base_url: "http://example.test"
    )

    expect(described_class.deliveries.length).to eq(2)
    mail = described_class.deliveries.first
    expect(mail.subject).to eq("The Walter Scott case has been updated on EBWiki.")
    expect(mail.html).to include("Case editor John")
    expect(mail.html).to include("Corrected city spelling")
    expect(mail.html).to include("http://example.test/cases/walter-scott")
  end

  it "sends a deletion email with the Rails subject" do
    described_class.send_deletion_email(users: [user], this_case: this_case)

    mail = described_class.deliveries.last
    expect(mail.to).to eq("editor@example.com")
    expect(mail.subject).to eq("The Walter Scott case has been removed from EBWiki")
    expect(mail.html).to include("removed the Walter Scott case")
  end

  it "escapes HTML in names and comments" do
    described_class.send_followers_email(
      users: [user],
      this_case: {title: "A <b>Case</b>", slug: "a-case"},
      editor_name: "<script>x</script>",
      comment: "said \"hi\" & more",
      base_url: "http://example.test"
    )

    html = described_class.deliveries.last.html
    expect(html).to include("&lt;script&gt;x&lt;/script&gt;")
    expect(html).to include("A &lt;b&gt;Case&lt;/b&gt;")
    expect(html).to include("said &quot;hi&quot; &amp; more")
  end

  it "requires an explicit send flag and SMTP settings before transmitting" do
    expect(described_class.send_mail_enabled?).to be(false)
    expect(described_class.smtp_configured?).to be(false)

    ENV["HANAMI_SEND_MAIL"] = "1"
    ENV["SMTP_ADDRESS"] = "smtp.example.com"
    ENV["SMTP_PASSWORD"] = "secret"

    expect(described_class.send_mail_enabled?).to be(true)
    expect(described_class.smtp_configured?).to be(true)
    expect(described_class.transmit?).to be(false)
  ensure
    ENV.delete("HANAMI_SEND_MAIL")
    ENV.delete("SMTP_ADDRESS")
    ENV.delete("SMTP_PASSWORD")
  end
end
