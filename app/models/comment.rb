# frozen_string_literal: true

# Comments on the case
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  # Model Validations
  sanitize :content

  validates :content, presence: true

  # Scopes
  scope :sorted_by_creation, ->(limit) { order(created_at: :desc).limit(limit) }
end
