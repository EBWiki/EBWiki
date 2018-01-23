# frozen_string_literal: true

class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  # Scopes
  scope :sorted_by_creation, ->(limit) { order(created_at: :desc).limit(limit) }
end
