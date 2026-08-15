# frozen_string_literal: true

class Conversation < ApplicationRecord
  belongs_to :originator, class_name: 'User', optional: true
  has_many :messages, dependent: :destroy
  has_many :participants, class_name: 'ConversationParticipant', dependent: :destroy
  has_many :users, through: :participants

  validates :subject, presence: true

  scope :for_user, lambda { |user|
    joins(:participants).where(conversation_participants: { user_id: user.id }).distinct
  }

  scope :inbox, lambda { |user|
    for_user(user)
      .where(conversation_participants: { trashed: false })
      .where.not(originator_id: user.id)
  }

  scope :sentbox, lambda { |user|
    for_user(user)
      .where(conversation_participants: { trashed: false })
      .where(originator_id: user.id)
  }

  scope :trashed, lambda { |user|
    for_user(user).where(conversation_participants: { trashed: true })
  }

  def receipts_for(_user)
    messages.order(:created_at)
  end

  def mark_as_read(user)
    participants.find_by(user: user)&.update(read_at: Time.current)
  end

  def move_to_trash(user)
    participants.find_by(user: user)&.update(trashed: true)
  end

  def untrash(user)
    participants.find_by(user: user)&.update(trashed: false)
  end

  def is_trashed?(user)
    participants.find_by(user: user)&.trashed?
  end

  def count_messages
    messages.count
  end

  def originator
    super || messages.order(:created_at).first&.sender
  end
end
