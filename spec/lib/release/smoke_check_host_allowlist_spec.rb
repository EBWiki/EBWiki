# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::SmokeCheckHostAllowlist do
  describe '.permitted!' do
    it 'allows default HTTPS hosts on the default port' do
      expect(described_class.permitted!('https://staging.ebwiki.org')).to be(true)
    end

    it 'refuses ebwiki.org by default' do
      previous = ENV.fetch('RELEASE_SMOKE_ALLOWED_HOSTS', nil)
      ENV.delete('RELEASE_SMOKE_ALLOWED_HOSTS')
      expect(described_class.permitted!('https://ebwiki.org')).to be(false)
    ensure
      ENV['RELEASE_SMOKE_ALLOWED_HOSTS'] = previous unless previous.nil?
    end

    it 'allows ebwiki.org when explicitly allowlisted' do
      previous = ENV.fetch('RELEASE_SMOKE_ALLOWED_HOSTS', nil)
      ENV['RELEASE_SMOKE_ALLOWED_HOSTS'] = 'staging.ebwiki.org,ebwiki.org'
      expect(described_class.permitted!('https://ebwiki.org')).to be(true)
    ensure
      if previous.nil?
        ENV.delete('RELEASE_SMOKE_ALLOWED_HOSTS')
      else
        ENV['RELEASE_SMOKE_ALLOWED_HOSTS'] = previous
      end
    end

    it 'refuses lookalike hostnames' do
      expect(described_class.permitted!('https://notebwiki.org')).to be(false)
      expect(described_class.permitted!('https://staging.ebwiki.org.evil.com')).to be(false)
    end

    it 'refuses plain HTTP' do
      expect(described_class.permitted!('http://staging.ebwiki.org')).to be(false)
    end

    it 'refuses embedded userinfo' do
      expect(described_class.permitted!('https://user:pw@staging.ebwiki.org')).to be(false)
    end

    it 'refuses a non-default HTTPS port' do
      expect(described_class.permitted!('https://staging.ebwiki.org:8443')).to be(false)
    end
  end
end
