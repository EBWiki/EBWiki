class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :articles
  geocoded_by :current_sign_in_ip   # can also be an IP address
  before_save :geocode  # auto-fetch coordinates when user logs in



end
