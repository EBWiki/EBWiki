# frozen_string_literal: true

class MessageDelivery
  attr_reader :conversation, :message

  def initialize(conversation:, message:)
    @conversation = conversation
    @message = message
  end
end
