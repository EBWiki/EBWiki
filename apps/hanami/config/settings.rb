# frozen_string_literal: true

module EbWiki
  class Settings < Hanami::Settings
    setting :session_secret, constructor: ->(value) { value.to_s }
  end
end
