# frozen_string_literal: true

# Setup for the Ahoy datastore
class Ahoy::Store < Ahoy::DatabaseStore
  # customize here
  Ahoy.api = true
  Ahoy.user_agent_parser = :device_detector

  def exclude?
    bot? || request.ip == '192.168.1.1'
  end
end
