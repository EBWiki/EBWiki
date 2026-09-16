# frozen_string_literal: true

RSpec.describe EbWiki::Geocode do
  it "skips the network in the test environment" do
    expect(described_class.lookup(address: "123 Main", city: "Charleston")).to be_nil
  end
end
