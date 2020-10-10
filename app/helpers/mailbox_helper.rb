# frozen_string_literal: true

# Helper for the EB Wiki mailbox
module MailboxHelper
  def unread_messages_count
    # how to get the number of unread messages for the current user
    # using mailboxer
    mailbox.inbox(unread: true).count
  end
end
