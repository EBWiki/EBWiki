# frozen_string_literal: true

# Comments on the case
class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  STRIPPED_ATTRIBUTES = %w[content].freeze
  auto_strip_attributes(*STRIPPED_ATTRIBUTES)

  # Scopes
  scope :sorted_by_creation, ->(limit) { order(created_at: :desc).limit(limit) }
end
