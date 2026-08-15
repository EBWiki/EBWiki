# frozen_string_literal: true

class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :user_id, uniqueness: { scope: :conversation_id }
end
