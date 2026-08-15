# frozen_string_literal: true

# User model
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :comments, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :sent_messages, class_name: 'Message', foreign_key: :sender_id, dependent: :destroy,
                           inverse_of: :sender
  acts_as_follower
  extend FriendlyId

  friendly_id :slug_candidates, use: %i[slugged finders]

  # Model validations
  sanitize :email, :name, :description, :city, :facebook_url, :twitter_url, :linkedin

  validates :name, presence: { message: 'Please add a name.' }

  def mailbox
    UserMailbox.new(self)
  end

  def send_message(recipients, body, subject)
    conversation = Conversation.create!(subject: subject, originator: self)
    ([self] + Array(recipients)).uniq.each do |participant|
      conversation.participants.find_or_create_by!(user: participant)
    end
    message = conversation.messages.create!(sender: self, body: body)
    notify_participants(conversation, message, reply: false)
    message
  end

  def reply_to(conversation, body)
    message = conversation.messages.create!(sender: self, body: body)
    notify_participants(conversation, message, reply: true)
    message
  end

  def slug_candidates
    [
      :name,
      %i[name id]
    ]
  end

  def mailchimp_status
    case mailchimp_user
    when Array
      nil
    when Hash
      mailchimp_user['status']
    end
  end

  private

  def notify_participants(conversation, message, reply:)
    conversation.users.where.not(id: id).find_each do |recipient|
      mail = if reply
               ConversationMailer.reply_message(message: message, recipient: recipient)
             else
               ConversationMailer.new_message(message: message, recipient: recipient)
             end
      mail.deliver_later
    end
  end

  def mailchimp_user
    gb = Gibbon::Request.new
    gb.lists(ENV.fetch('MAILCHIMP_LIST_ID',
                       nil)).members(Digest::MD5.hexdigest(email.downcase.to_s)).retrieve
  rescue Gibbon::MailChimpError => e
    [nil, { flash: { error: e.message } }]
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  admin                  :boolean          default(FALSE)
#  analyst                :boolean          default(FALSE)
#  city                   :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  description            :text
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  facebook_url           :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  latitude               :float
#  linkedin               :string
#  longitude              :float
#  name                   :string           not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  slug                   :string
#  state                  :string
#  subscribed             :boolean
#  twitter_url            :string
#  created_at             :datetime
#  updated_at             :datetime
#  state_id               :integer
#
# Indexes
#
#  index_users_on_admin                 (admin)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_created_at            (created_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_slug                  (slug) UNIQUE
#
