# frozen_string_literal: true

# Readiness endpoint (GET /health). Skips ApplicationController filters.
class HealthController < ActionController::Base # rubocop:disable Rails/ApplicationController -- skip DB-heavy before_actions
  def show
    payload = Health::ReadinessChecks.call
    rev = deploy_revision
    payload[:deploy_rev] = rev if rev

    http_status = payload[:status] == 'ok' ? :ok : :service_unavailable
    render json: payload, status: http_status
  end

  private

  def deploy_revision
    ENV['DEPLOY_REV'].presence || ENV['RAILWAY_GIT_COMMIT_SHA'].presence
  end
end
