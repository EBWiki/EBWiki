# frozen_string_literal: true

require 'observer'

# EBWiki site user
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: { message: 'Please add a name.' }

  has_many :cases
  has_many :comments
  acts_as_follower
  acts_as_messageable
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[slugged finders]

  scope :recent_editors, -> {
    where(recent_editor: true )
  }

  def mailboxer_name
    name
  end

  def mailboxer_email(_object)
    email
  end

  def slug_candidates
    [
      :name,
      %i[name id]
    ]
  end

  def mailchimp_status
    if mailchimp_user.is_a?(Array)
      nil
    elsif mailchimp_user.is_a?(Hash)
      mailchimp_user['status']
    end
  end

  def versions
    PaperTrail::Version.where(whodunnit: id)
  end

  def recent_edits(period)
    versions.where('created_at > ?', period.days.ago)
  end

  def recent_editor
    versions.where('created_at > ?', 30.days.ago).count >=1
  end

  private

  def mailchimp_user
    gb = Gibbon::Request.new
    gb.lists(ENV['MAILCHIMP_LIST_ID']).members(Digest::MD5.hexdigest(email.downcase.to_s)).retrieve
  rescue Gibbon::MailChimpError => e
    [nil, flash: { error: e.message }]
  end
end
