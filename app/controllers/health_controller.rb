# frozen_string_literal: true

# Readiness endpoint (GET /health). Skips ApplicationController filters that hit the DB.
class HealthController < ApplicationController
  skip_before_action :store_user_location!, raise: false
  skip_before_action :set_state_objects, raise: false
  skip_before_action :set_paper_trail_whodunnit, raise: false

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
