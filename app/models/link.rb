# frozen_string_literal: true

# associate Case property
class Link < ActiveRecord::Base
  belongs_to :case
  validates :url, presence: true
  belongs_to :linkable, polymorphic: true
end
