# frozen_string_literal: true

require "bcrypt"
require "securerandom"

module EbWiki
  module Repos
    class UserRepo < EbWiki::DB::Repo
      def by_id(id)
        users.where(id: id).one
      end

      def find_profile(id_or_slug)
        if id_or_slug.to_s.match?(/\A\d+\z/)
          users.where(id: Integer(id_or_slug)).one
        else
          users.where(slug: id_or_slug.to_s).one
        end
      end

      def by_email(email)
        users.where(email: email.to_s.strip.downcase).one
      end

      def followed_cases(user_id)
        follow_ids = follows.where(
          follower_type: "User",
          follower_id: user_id,
          followable_type: "Case",
          blocked: false
        ).to_a.map(&:followable_id)
        return [] if follow_ids.empty?

        cases.where(id: follow_ids).order(cases[:updated_at].desc).to_a
      end

      def register(email:, password:, name:)
        now = Time.now.utc
        token = SecureRandom.hex(20)
        slug = unique_slug(name)
        id = users.insert(
          email: email.to_s.strip.downcase,
          encrypted_password: BCrypt::Password.create(password),
          name: name.to_s.strip,
          slug: slug,
          confirmation_token: token,
          confirmation_sent_at: now,
          confirmed_at: nil,
          admin: false,
          analyst: false,
          sign_in_count: 0,
          created_at: now,
          updated_at: now
        )
        users.where(id: id).one
      end

      def confirm(token)
        user = users.where(confirmation_token: token.to_s).one
        return unless user

        users.where(id: user.id).update(
          confirmed_at: Time.now.utc,
          confirmation_token: nil,
          updated_at: Time.now.utc
        )
        by_id(user.id)
      end

      def request_password_reset(email)
        user = by_email(email)
        return unless user

        token = SecureRandom.hex(20)
        users.where(id: user.id).update(
          reset_password_token: token,
          reset_password_sent_at: Time.now.utc,
          updated_at: Time.now.utc
        )
        by_id(user.id)
      end

      def reset_password(token:, password:)
        user = users.where(reset_password_token: token.to_s).one
        return unless user

        users.where(id: user.id).update(
          encrypted_password: BCrypt::Password.create(password),
          reset_password_token: nil,
          reset_password_sent_at: nil,
          updated_at: Time.now.utc
        )
        by_id(user.id)
      end

      def update_profile(id, attrs)
        users.where(id: id).update(
          name: attrs[:name].to_s.strip,
          description: attrs[:description].to_s,
          updated_at: Time.now.utc
        )
        by_id(id)
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

      private

      def unique_slug(name)
        base = name.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
        base = "user" if base.empty?
        return base unless users.where(slug: base).one

        "#{base}-#{SecureRandom.hex(3)}"
      end
    end
  end
end
