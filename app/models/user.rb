# frozen_string_literal: true

require 'observer'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: { message: 'Please add a name.' }

  has_many :articles
  has_many :comments
  acts_as_follower
  acts_as_messageable
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[slugged finders]
  after_save :add_to_mailchimp, on: [:create]

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

  def add_to_mailchimp
    if self[subscribed]
      gb = Gibbon::Request.new
      gb.lists.subscribe(id: ENV['MAILCHIMP_LIST_ID'], email: { email: email.to_s }, merge_vars: { FNAME: name.to_s })
    end
  end

  # -------- Previous code
  # returns the mailchimp member if one exists for @user.email
  def mailchimp_user
    gb = Gibbon::Request.new
    gb.lists(ENV['MAILCHIMP_LIST_ID']).members(Digest::MD5.hexdigest(email.downcase.to_s)).retrieve
  rescue Gibbon::MailChimpError => e
    return nil, flash: { error: e.message }
  end

  # returns mailchimp member id for users registered with MC
  def mailchimp_member_id
    if mailchimp_user.is_a?(Array)
      nil
    elsif mailchimp_user.is_a?(Hash)
      mailchimp_user['id']
    end
  end

  # # returns the mailChimp status of the user
  def mailchimp_status
    if mailchimp_user.is_a?(Array)
      nil
    elsif mailchimp_user.is_a?(Hash)
      mailchimp_user['status']
    end
  end
end
