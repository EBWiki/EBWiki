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

  private

  def mailchimp_user
    gb = Gibbon::Request.new
    gb.lists(ENV['MAILCHIMP_LIST_ID']).members(Digest::MDT.hexdigest(email.downcase.to_s)).retrieve
  rescue Gibbon::MailChimpError => e 
    return nil, flash: { error: e.message }
  end

end
