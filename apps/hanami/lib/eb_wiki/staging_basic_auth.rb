# frozen_string_literal: true

require "rack"

module EbWiki
  # Browser gate for public staging. Enabled only when both
  # HTTP_BASIC_AUTH_USER and HTTP_BASIC_AUTH_PASSWORD are set.
  # /up stays open so Railway healthchecks are not blocked.
  class StagingBasicAuth
    REALM = "EBWiki staging"
    HEALTHCHECK_PATH = "/up"

    def initialize(app)
      @app = app
    end

    def call(env)
      return healthcheck_ok if env["PATH_INFO"] == HEALTHCHECK_PATH
      return @app.call(env) unless required?

      auth = Rack::Auth::Basic::Request.new(env)
      return @app.call(env) if auth.provided? && auth.basic? && credentials_match?(auth)

      unauthorized
    end

    private

    def required?
      username.bytesize.positive? && password.bytesize.positive?
    end

    def credentials_match?(auth)
      Rack::Utils.secure_compare(auth.username.to_s, username) &
        Rack::Utils.secure_compare(auth.credentials[1].to_s, password)
    end

    def username
      ENV.fetch("HTTP_BASIC_AUTH_USER", "")
    end

    def password
      ENV.fetch("HTTP_BASIC_AUTH_PASSWORD", "")
    end

    def unauthorized
      [
        401,
        {
          "content-type" => "text/plain; charset=utf-8",
          "www-authenticate" => %(Basic realm="#{REALM}")
        },
        ["Unauthorized"]
      ]
    end

    def healthcheck_ok
      [200, {"content-type" => "text/plain; charset=utf-8"}, ["ok"]]
    end
  end
end
