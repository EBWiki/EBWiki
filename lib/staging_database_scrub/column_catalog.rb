# frozen_string_literal: true

module StagingDatabaseScrub
  # Columns inspected for personal data, tokens, and IP addresses (from db/structure.sql).
  module ColumnCatalog
    SCRUBBED_EMAIL_DOMAIN = '@example.invalid'

    USER_PERSONAL_TEXT_COLUMNS = %i[
      name
      description
      city
      state
      facebook_url
      twitter_url
      linkedin
      storytime_name
    ].freeze

    USER_NULLABLE_LOCATION_COLUMNS = %i[latitude longitude].freeze

    USER_TOKEN_COLUMNS = %i[
      reset_password_token
      confirmation_token
    ].freeze

    USER_PASSWORD_DIGEST_COLUMN = :encrypted_password

    USER_IP_COLUMNS = %i[
      current_sign_in_ip
      last_sign_in_ip
    ].freeze

    VERSION_IP_COLUMN = :ip

    VERSION_PERSONAL_TEXT_COLUMNS = %i[whodunnit].freeze

    VERSION_USER_HISTORY_COLUMNS = %i[object object_changes].freeze

    VISIT_IP_COLUMN = :ip

    CHECKED_COLUMNS = {
      'users.email' => 'Replaced with unique scrubbed addresses ending in @example.invalid',
      'users.name' => 'Replaced with scrubbed placeholder names',
      'users.description' => 'Replaced with scrubbed placeholder text',
      'users.city' => 'Replaced with scrubbed placeholder text',
      'users.state' => 'Replaced with scrubbed placeholder text',
      'users.facebook_url' => 'Replaced with scrubbed placeholder text',
      'users.twitter_url' => 'Replaced with scrubbed placeholder text',
      'users.linkedin' => 'Replaced with scrubbed placeholder text',
      'users.storytime_name' => 'Replaced with scrubbed placeholder text',
      'users.slug' => 'Replaced with unique scrubbed slugs',
      'users.latitude' => 'Set to NULL',
      'users.longitude' => 'Set to NULL',
      'users.encrypted_password' => 'Set to NULL (NOT NULL constraint dropped on scrub target)',
      'users.reset_password_token' => 'Set to NULL',
      'users.confirmation_token' => 'Set to NULL',
      'users.current_sign_in_ip' => 'Set to NULL',
      'users.last_sign_in_ip' => 'Set to NULL',
      'sessions' => 'All rows deleted',
      'versions.ip' => 'Set to NULL',
      'versions.whodunnit' => 'Non-numeric values replaced; numeric user ids retained',
      'versions.object' => 'Cleared for User version rows only',
      'versions.object_changes' => 'Cleared for User version rows only',
      'visits.ip' => 'Set to NULL'
    }.freeze

    def self.all_checked_columns
      CHECKED_COLUMNS
    end

    def self.token_columns_for_assertion
      USER_TOKEN_COLUMNS.map { |column| [:users, column] }
    end

    def self.password_digest_columns_for_assertion
      [[:users, USER_PASSWORD_DIGEST_COLUMN]]
    end

    def self.ip_columns_for_assertion
      USER_IP_COLUMNS.map { |column| [:users, column] } +
        [[:versions, VERSION_IP_COLUMN], [:visits, VISIT_IP_COLUMN]]
    end
  end
end
