# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_type :string
#  content          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  commentable_id   :integer
#  user_id          :integer
#
# Indexes
#
#  index_comments_on_commentable_id_and_commentable_type  (commentable_id,commentable_type)
#
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
