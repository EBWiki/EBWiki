# frozen_string_literal: true

# Mailbox Controller. Part of EBWiki messages
class MailboxController < ApplicationController
  before_action :authenticate_user!
  def inbox
    @inbox = mailbox.inbox
    @active = :inbox
  end

  def sent
    @sent = mailbox.sentbox
    @active = :sent
  end

  def trash
    @trash = mailbox.trash
    @active = :trash
  end
end
