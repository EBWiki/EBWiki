# frozen_string_literal: true

# Expose deploy revision on /up JSON for live SHA checks (Railway sets
# RAILWAY_GIT_COMMIT_SHA; operators may override with DEPLOY_REV).
Rails.application.config.to_prepare do
  Rails::HealthController.class_eval do
    private

    def render_up
      respond_to do |format|
        format.html { render html: html_status(color: 'green') }
        format.json do
          payload = { status: 'up', timestamp: Time.current.iso8601 }
          rev = ENV['DEPLOY_REV'].presence || ENV['RAILWAY_GIT_COMMIT_SHA'].presence
          payload[:deploy_rev] = rev if rev
          render json: payload
        end
      end
    end
  end
end
