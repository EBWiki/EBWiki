# frozen_string_literal: true

# A model for acts_as_follower
class Follow < ActiveRecord::Base
  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the 'followable' interface, and also to followers
  belongs_to :followable, polymorphic: true, counter_cache: true
  belongs_to :follower,   polymorphic: true

  # Scopes
  scope :occurring_by, ->(date) { where("created_at < ?", date.end_of_day) }

  def block!
    update_attribute(:blocked, true)
  end
end
