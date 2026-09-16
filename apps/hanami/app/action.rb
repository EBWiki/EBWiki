# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"
require "eb_wiki/mailer"
require "eb_wiki/carrier_wave_avatar"
require "eb_wiki/rails_session"

module EbWiki
  class Action < Hanami::Action
    include Dry::Monads[:result]
    include Deps["repos.user_repo", "repos.session_repo"]

    before :set_current_user

    private

    def set_current_user(request, response)
      response[:current_user] = EbWiki::RailsSession.current_user(
        request,
        user_repo: user_repo,
        session_repo: session_repo
      )
    end

    def current_user(response)
      response[:current_user]
    end

    def sign_in!(request, response, user)
      EbWiki::RailsSession.sign_in!(request, response, user, session_repo: session_repo)
    end

    def sign_out!(request, response)
      EbWiki::RailsSession.sign_out!(request, response, session_repo: session_repo)
    end

    def require_user!(response)
      return if current_user(response)

      response.redirect_to "/login"
    end

    def require_admin!(response)
      user = current_user(response)
      halt 403 unless user&.admin
    end

    def public_base_url(request)
      configured = ENV["APP_URL"].to_s.strip
      return configured.chomp("/") unless configured.empty?

      request.base_url.to_s.chomp("/")
    end

    def apply_case_avatar(record, request, repo)
      raw = request.params[:case] || request.params
      remove = raw[:remove_avatar] || raw["remove_avatar"]
      if remove.to_s == "1"
        EbWiki::CarrierWaveAvatar.remove(record)
        repo.clear_avatar(record.id)
        return
      end

      stored = EbWiki::CarrierWaveAvatar.store(record: record, upload: raw[:avatar] || raw["avatar"])
      return unless stored

      repo.set_avatar(record.id, **stored)
    end
  end
end
