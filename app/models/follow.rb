# frozen_string_literal: true

# A model for acts_as_follower
class Follow < ApplicationRecord
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

  def mom_follows_growth
    last_month_follows = Follow.this_month.count
    return 0 if last_month_follows.zero?
    previous_follows = Follow.count - last_month_follows
    return (last_month_follows * 100) if previous_follows.zero?

    (last_month_follows.to_f / previous_follows * 100).round(2)
  end

  def mom_unique_followers_growth
    last_month_followers = Follow.this_month.distinct.count('follower_id')
    return 0 if last_month_followers.zero?
    previous_distinct_followers = Follow.distinct.count('follower_id') - last_month_followers
    return 0 if previous_distinct_followers.zero?

    (last_month_followers.to_f / previous_distinct_followers * 100).round(2)
  end
end
