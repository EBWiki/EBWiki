# frozen_string_literal: true

# Follow model
class Follow < ApplicationRecord
  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the 'followable' interface, and also to followers
  belongs_to :followable, polymorphic: true, counter_cache: true
  belongs_to :follower,   polymorphic: true

  # Scopes
  scope :occurring_by, ->(date) { where('created_at < ?', date.end_of_day) }

  def block!
    update_attribute(:blocked, true)
  end
end

# == Schema Information
#
# Table name: follows
#
#  id              :integer          not null, primary key
#  blocked         :boolean          default(FALSE), not null
#  followable_type :string           not null
#  follower_type   :string           not null
#  created_at      :datetime
#  updated_at      :datetime
#  followable_id   :integer          not null
#  follower_id     :integer          not null
#
# Indexes
#
#  fk_followables               (followable_id,followable_type)
#  fk_follows                   (follower_id,follower_type)
#  index_follows_on_created_at  (created_at)
#

