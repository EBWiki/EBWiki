# frozen_string_literal: true

# A model for acts_as_follower
class Follow < ActiveRecord::Base
  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the 'followable' interface, and also to followers
  belongs_to :followable, polymorphic: true, counter_cache: true
  belongs_to :follower,   polymorphic: true

  # Scopes
  scope :this_month, -> { where(created_at: 30.days.ago.beginning_of_day..Time.current) }

  def block!
    update_attribute(:blocked, true)
  end
end
