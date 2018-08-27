
# frozen_string_literal: true

class Ahoy::Store < Ahoy::DatabaseStore
  # customize here
  Ahoy.api = true

  def exclude?
    bot? || request.ip == '192.168.1.1'
  end
end
