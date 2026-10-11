# frozen_string_literal: true

# /up liveness: deploy revision in JSON and 503 (not 500) when the check errors.
Rails.application.config.after_initialize do
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

    def render_down
      respond_to do |format|
        format.html { render html: html_status(color: 'red'), status: :service_unavailable }
        format.json do
          render json: { status: 'down', timestamp: Time.current.iso8601 },
                 status: :service_unavailable
        end
      end
    end
  end
end
