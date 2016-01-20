require 'observer'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :articles
  has_many :comments
  geocoded_by :current_sign_in_ip   # can also be a street address
  before_save :geocode  # auto-fetch coordinates when user logs in
  acts_as_follower
  acts_as_messageable
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
  after_validation :add_to_mailchimp
 
  def mailboxer_name
    self.name
  end
 
  def mailboxer_email(object)
    self.email
  end

  def slug_candidates
    [
      :name,
      [:name, :id]
    ]
  end

  def add_to_mailchimp
    if self.subscribed?
      gb = Gibbon::API.new
      gb.lists.subscribe({:id => ENV['MAILCHIMP_LIST_ID'], :email => {:email => "#{self.email}"}, :merge_vars => {:FNAME => "#{self.name}"}})
    end
  end
end
