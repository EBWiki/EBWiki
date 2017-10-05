# frozen_string_literal: true

class Ahoy::Store < Ahoy::Stores::ActiveRecordStore
  # customize here
  def exclude?
    bot? || request.ip == '192.168.1.1'
  end
end
