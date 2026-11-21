# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotoSearch::ReviewDatabaseScrub do
  describe '.scrub!' do
    let!(:user) do
      create(
        :user,
        email: 'real.person@company.com',
        name: 'Real Person',
        facebook_url: 'https://facebook.com/real',
        current_sign_in_ip: '203.0.113.10',
        reset_password_token: 'secret-token',
        confirmation_token: 'confirm-token'
      )
    end

    before { described_class.scrub! }

    it 'replaces contributor email with example.invalid' do
      user.reload
      expect(user.email).to eq("user-#{user.id}@example.invalid")
    end

    it 'clears tokens and sign-in IPs' do
      user.reload
      expect(user.reset_password_token).to be_nil
      expect(user.confirmation_token).to be_nil
      expect(user.current_sign_in_ip).to be_nil
      expect(user.last_sign_in_ip).to be_nil
    end

    it 'sets a non-login password digest sentinel' do
      user.reload
      expect(user.encrypted_password).to eq(described_class.scrubbed_password_digest)
      expect(user.valid_password?('password')).to be(false)
    end

    it 'passes post-scrub assertions' do
      result = PhotoSearch::ReviewDatabaseAssertions.run
      expect(result.ok).to be(true), result.errors.join(', ')
    end
  end
end
