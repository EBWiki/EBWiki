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
  storytime_user
  acts_as_messageable
 
  def mailboxer_name
    self.name
  end
 
  def mailboxer_email(object)
    self.email
  end
end
