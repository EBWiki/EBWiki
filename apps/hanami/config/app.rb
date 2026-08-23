# frozen_string_literal: true

require "hanami"

module EbWiki
  class App < Hanami::App
    config.actions.sessions = :cookie, {
      key: "ebwiki.session",
      secret: settings.session_secret,
      expire_after: 60 * 60 * 24 * 14
    }
    config.actions.csrf_protection = false if Hanami.env?(:test)
  end
end
