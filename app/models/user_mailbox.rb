# frozen_string_literal: true

class UserMailbox
  def initialize(user)
    @user = user
  end

  def inbox(unread: false)
    scope = Conversation.inbox(@user)
    return scope unless unread

    scope.where(conversation_participants: { read_at: nil })
  end

  def sent
    Conversation.sent(@user)
  end

  def trash
    Conversation.trashed(@user)
  end

  def conversations
    Conversation.for_user(@user)
  end
end
