# frozen_string_literal: true

class UserMailbox
  def initialize(user)
    @user = user
  end

  def inbox
    Conversation.inbox(@user)
  end

  def sentbox
    Conversation.sentbox(@user)
  end

  def trash
    Conversation.trashed(@user)
  end

  def conversations
    Conversation.for_user(@user)
  end
end
