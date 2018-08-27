# frozen_string_literal: true

# Comments on the case
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  # Scopes
  scope :sorted_by_creation, ->(limit) { order(created_at: :desc).limit(limit) }
end
