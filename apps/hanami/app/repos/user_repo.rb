# frozen_string_literal: true

require "bcrypt"

module EbWiki
  module Repos
    class UserRepo < EbWiki::DB::Repo
      def by_id(id)
        users.where(id: id).one
      end

      def by_email(email)
        users.where(email: email.to_s.strip.downcase).one
      end

      def authenticate(email:, password:)
        user = by_email(email)
        return unless user
        return unless user.confirmed_at
        return unless valid_password?(user.encrypted_password, password)

        user
      end

      def search_by_email(query)
        q = query.to_s.strip
        return users.order(users[:email].asc).limit(50).to_a if q.empty?

        users.where(Sequel.ilike(:email, "%#{q}%")).order(users[:email].asc).limit(50).to_a
      end

      def update_roles(id, admin:, analyst:)
        users.where(id: id).update(admin: admin, analyst: analyst, updated_at: Time.now.utc)
      end

      def valid_password?(encrypted_password, password)
        BCrypt::Password.new(encrypted_password.to_s) == password.to_s
      rescue BCrypt::Errors::InvalidHash
        false
      end
    end
  end
end
