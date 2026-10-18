# frozen_string_literal: true

# HTTP basic auth for staging: covers all routes; only paths in EXEMPT_PATHS skip auth.
class StagingBasicAuth
  EXEMPT_PATHS = ['/up'].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    return @app.call(env) if EXEMPT_PATHS.include?(request.path)
    return unauthorized unless staging_credentials_configured?
    return unauthorized unless authenticated?(env)

    @app.call(env)
  end

  private

  def staging_credentials_configured?
    ENV.fetch('STAGING_USERNAME', nil).present? &&
      ENV.fetch('STAGING_PASSWORD', nil).present?
  end

  def authenticated?(env)
    auth = Rack::Auth::Basic::Request.new(env)
    return false unless auth.provided? && auth.basic?

    credentials_match?(
      auth,
      ENV.fetch('STAGING_USERNAME', nil).to_s,
      ENV.fetch('STAGING_PASSWORD', nil).to_s
    )
  end

  def credentials_match?(auth, expected_username, expected_password)
    user, pass = auth.credentials
    ActiveSupport::SecurityUtils.secure_compare(user.to_s, expected_username) &
      ActiveSupport::SecurityUtils.secure_compare(pass.to_s, expected_password)
  end

  def unauthorized
    [
      401,
      {
        'Content-Type' => 'text/plain',
        'WWW-Authenticate' => 'Basic realm="Staging"'
      },
      ['Unauthorized']
    ]
  end
end
