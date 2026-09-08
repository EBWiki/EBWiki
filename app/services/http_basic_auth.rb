# frozen_string_literal: true

require 'digest'

# Optional HTTP Basic Auth for staging and preview environments.
# Production stays public unless HTTP_BASIC_AUTH_ENABLED is explicitly set.
class HttpBasicAuth
  REALM = 'EBWiki'
  ENABLED_FLAG = 'true'
  LEGACY_HOST = 'ebwiki-newstack.herokuapp.com'

  def self.required?
    credentials_present? && enabled_for_environment?
  end

  def self.username
    first_present_env('HTTP_BASIC_AUTH_USERNAME', 'STAGING_USERNAME')
  end

  def self.password
    first_present_env('HTTP_BASIC_AUTH_PASSWORD', 'STAGING_PASSWORD')
  end

  def self.credentials_match?(given_username, given_password)
    secure_match?(given_username, username) && secure_match?(given_password, password)
  end

  def self.credentials_present?
    username.present? && password.present?
  end

  def self.enabled_for_environment?
    return true if ENV.fetch('HTTP_BASIC_AUTH_ENABLED', nil) == ENABLED_FLAG
    return true if legacy_staging_host?
    return true if staging_environment?

    false
  end

  def self.legacy_staging_host?
    ENV.fetch('HOST', nil) == LEGACY_HOST
  end

  def self.staging_environment?
    # rubocop:disable Rails/UnknownEnv -- staging is a valid custom environment
    Rails.env.staging?
    # rubocop:enable Rails/UnknownEnv
  end
  private_class_method :staging_environment?

  def self.first_present_env(*keys)
    keys.each do |key|
      value = ENV.fetch(key, nil)
      return value if value.present?
    end

    nil
  end
  private_class_method :first_present_env

  def self.secure_match?(actual, expected)
    return false if actual.blank? || expected.blank?

    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(actual),
      Digest::SHA256.hexdigest(expected)
    )
  end
  private_class_method :secure_match?
end
