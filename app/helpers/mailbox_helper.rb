# frozen_string_literal: true

# Helper for the EB Wiki mailbox
module MailboxHelper
  def unread_messages_count
    return 0 unless current_user

    current_user.mailbox.inbox(unread: true).count
  end
end
