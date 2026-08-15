# frozen_string_literal: true

class ConversationMailer < ApplicationMailer
  def new_message(message:, recipient:)
    @message = message
    @recipient = recipient
    mail(
      to: recipient.email,
      subject: "You received a new EBWiki message about #{message.subject}"
    )
  end

  def reply_message(message:, recipient:)
    @message = message
    @recipient = recipient
    mail(
      to: recipient.email,
      subject: "You received a new reply on EBWiki about #{message.subject}"
    )
  end
end
