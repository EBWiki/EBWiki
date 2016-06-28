class Follow < ActiveRecord::Base

  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, :polymorphic => true, :counter_cache => true
  belongs_to :follower,   :polymorphic => true

  def block!
    self.update_attribute(:blocked, true)
  end

  def mom_follows_growth
    last_month_follows = Follow.where(created_at: 30.days.ago..Time.now).count

    return (last_month_follows.to_f / (Follow.count-last_month_follows) * 100).round(2)
  end

  def mom_uniq_followers_growth
    last_month_followers = Follow.where(created_at: 30.days.ago..Time.now).distinct.count('follower_id')

    return (last_month_followers.to_f / (Follow.distinct.count('follower_id')-last_month_followers) * 100).round(2)
  end

end
