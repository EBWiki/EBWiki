# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::SmokeCheckCli do
  it 'refuses a non-allowlisted host before any HTTP smoke check runs' do
    allow(Release::SmokeCheck).to receive(:new)

    result = described_class.run(['https://evil.example.com'])

    expect(result).to be(false)
    expect(Release::SmokeCheck).not_to have_received(:new)
  end

  it 'refuses lookalike, HTTP, and userinfo URLs before any HTTP smoke check runs' do
    allow(Release::SmokeCheck).to receive(:new)

    %w[
      https://notebwiki.org
      https://staging.ebwiki.org.evil.com
      http://staging.ebwiki.org
      https://user:pw@ebwiki.org
    ].each do |url|
      expect(described_class.run([url])).to be(false)
    end

    expect(Release::SmokeCheck).not_to have_received(:new)
  end

  it 'runs the smoke check for an allowlisted host' do
    check = instance_double(Release::SmokeCheck, call: true)
    allow(Release::SmokeCheck).to receive(:new).and_return(check)

    expect(described_class.run(['https://staging.ebwiki.org'])).to be(true)
    expect(Release::SmokeCheck).to have_received(:new).with(base_url: 'https://staging.ebwiki.org')
  end
end
