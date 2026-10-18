# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release::SmokeCheckHostAllowlist do
  describe '.permitted!' do
    it 'allows default HTTPS hosts on the default port' do
      expect(described_class.permitted!('https://staging.ebwiki.org')).to be(true)
      expect(described_class.permitted!('https://ebwiki.org')).to be(true)
    end

    it 'refuses lookalike hostnames' do
      expect(described_class.permitted!('https://notebwiki.org')).to be(false)
      expect(described_class.permitted!('https://staging.ebwiki.org.evil.com')).to be(false)
    end

    it 'refuses plain HTTP' do
      expect(described_class.permitted!('http://staging.ebwiki.org')).to be(false)
    end

    it 'refuses embedded userinfo' do
      expect(described_class.permitted!('https://user:pw@ebwiki.org')).to be(false)
    end

    it 'refuses a non-default HTTPS port' do
      expect(described_class.permitted!('https://ebwiki.org:8443')).to be(false)
    end
  end
end
