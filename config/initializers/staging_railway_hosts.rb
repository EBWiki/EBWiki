# frozen_string_literal: true

# Allow Railway-generated hostnames when RAILS_ENV=staging.
# rubocop:disable Rails/UnknownEnv -- staging is a valid custom environment
if Rails.env.staging?
  Rails.application.config.hosts << /.+\.up\.railway\.app/
  Rails.application.config.hosts << /.+\.railway\.app/
  Rails.application.config.hosts << ENV['HOST'] if ENV['HOST'].present?
end
# rubocop:enable Rails/UnknownEnv
