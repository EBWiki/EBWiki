# frozen_string_literal: true

require "base64"
require "cgi"
require "openssl"
require "securerandom"

module EbWiki
  # Read and write Rails activerecord-session_store rows so Hanami and Rails
  # share `_eb_wiki_session` on the same host.
  #
  # Cookie = public session id. `sessions.session_id` = Rack private id
  # (`2::<sha256(public)>`), with a fallback to the public id for older rows.
  # Payload (activerecord-session_store 2.3 default):
  #   Base64.encode64(Marshal.dump(hash))
  # Devise key: "warden.user.user.key" => [[user.id], encrypted_password[0, 29]]
  module RailsSession
    COOKIE = "_eb_wiki_session"
    WARDEN_KEY = "warden.user.user.key"
    SALT_LENGTH = 29
    ID_VERSION = 2
    COOKIE_TTL = 60 * 60 * 24 * 14

    module_function

    def cookie_name
      COOKIE
    end

    def current_user(request, user_repo:, session_repo:)
      public_id = session_id_from_request(request)
      if usable_public_id?(public_id)
        row = find_row(session_repo, public_id)
        if row
          uid = user_id_from_data(row[:data])
          user = uid && user_repo.by_id(uid)
          return user if user && salt_matches?(user.encrypted_password, row[:data])
        end
      end

      user_id = request.session[:user_id]
      return unless user_id

      user_repo.by_id(user_id)
    end

    def sign_in!(request, response, user, session_repo:)
      request.session[:user_id] = user.id
      public_id = session_id_from_request(request)
      public_id = generate_session_id unless usable_public_id?(public_id)
      session_repo.upsert_for_user(
        session_id: private_id(public_id),
        user_id: user.id,
        encrypted_password: user.encrypted_password
      )
      write_cookie(response, public_id)
      public_id
    end

    def sign_out!(request, response, session_repo:)
      public_id = session_id_from_request(request)
      if public_id && !public_id.empty?
        session_repo.delete_by_session_id(private_id(public_id)) if usable_public_id?(public_id)
        session_repo.delete_by_session_id(public_id)
      end
      request.session[:user_id] = nil
      clear_cookie(response)
    end

    def session_id_from_request(request)
      raw = cookie_value(request.cookies)
      return nil if raw.nil? || raw.empty?

      CGI.unescape(raw.to_s)
    end

    def cookie_value(cookies)
      return unless cookies

      cookies[COOKIE] || cookies[COOKIE.to_sym]
    end

    def user_id_from_data(data)
      hash = unmarshal(data)
      return nil unless hash.is_a?(Hash)

      warden = hash[WARDEN_KEY] || hash[WARDEN_KEY.to_sym]
      return nil unless warden.is_a?(Array)

      ids = warden[0]
      ids.is_a?(Array) ? ids[0] : ids
    rescue TypeError, ArgumentError
      nil
    end

    def authenticatable_salt(encrypted_password)
      return nil if encrypted_password.nil? || encrypted_password.empty?

      encrypted_password.to_s[0, SALT_LENGTH]
    end

    def salt_matches?(encrypted_password, data)
      hash = unmarshal(data)
      return false unless hash.is_a?(Hash)

      warden = hash[WARDEN_KEY] || hash[WARDEN_KEY.to_sym]
      return false unless warden.is_a?(Array)

      authenticatable_salt(encrypted_password) == warden[1]
    rescue TypeError, ArgumentError
      false
    end

    def marshal(hash)
      Base64.encode64(Marshal.dump(hash))
    end

    def unmarshal(data)
      return {} if data.nil? || data.empty?

      Marshal.load(Base64.decode64(data.to_s)) # rubocop:disable Security/MarshalLoad
    end

    def payload_for(user_id, encrypted_password)
      marshal(
        WARDEN_KEY => [
          [Integer(user_id)],
          authenticatable_salt(encrypted_password)
        ]
      )
    end

    def generate_session_id
      SecureRandom.hex(16)
    end

    def private_id(public_id)
      "#{ID_VERSION}::#{OpenSSL::Digest::SHA256.hexdigest(public_id.to_s)}"
    end

    def usable_public_id?(value)
      !(value.nil? || value.empty? || value.to_s.match?(/\A\d+::/))
    end

    def find_row(repo, public_id)
      repo.find_by_session_id(private_id(public_id)) || repo.find_by_session_id(public_id)
    end

    def write_cookie(response, public_id)
      response.cookies[COOKIE] = {
        value: public_id,
        path: "/",
        httponly: true,
        same_site: "Lax",
        max_age: COOKIE_TTL
      }
    end

    def clear_cookie(response)
      response.cookies[COOKIE] = {
        value: "",
        path: "/",
        max_age: 0
      }
    end
  end
end
