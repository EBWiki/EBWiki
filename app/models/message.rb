# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'

  validates :body, presence: true

  delegate :subject, to: :conversation

  def message
    self
  end
end
