# frozen_string_literal: true

require "eb_wiki/rails_session"

RSpec.describe EbWiki::RailsSession do
  let(:password_digest) { "$2a$12$#{"a" * 53}" }

  it "round-trips a Devise warden payload" do
    data = described_class.payload_for(42, password_digest)

    expect(described_class.user_id_from_data(data)).to eq(42)
    expect(described_class.salt_matches?(password_digest, data)).to be(true)
    expect(described_class.salt_matches?("$2a$12$#{"b" * 53}", data)).to be(false)
  end

  it "stores the Rack private id Rails looks up from the cookie" do
    public_id = "abc123def456"
    expect(described_class.private_id(public_id)).to eq(
      "2::#{OpenSSL::Digest::SHA256.hexdigest(public_id)}"
    )
    expect(described_class.usable_public_id?(public_id)).to be(true)
    expect(described_class.usable_public_id?(described_class.private_id(public_id))).to be(false)
  end
end
