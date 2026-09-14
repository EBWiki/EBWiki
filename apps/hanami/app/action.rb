# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module EbWiki
  class Action < Hanami::Action
    include Dry::Monads[:result]
    include Deps["repos.user_repo"]

    before :set_current_user

    private

    def set_current_user(request, response)
      user_id = request.session[:user_id]
      response[:current_user] = user_id && user_repo.by_id(user_id)
    end

    def current_user(response)
      response[:current_user]
    end

    def require_user!(response)
      return if current_user(response)

      response.redirect_to "/login"
    end

    def require_admin!(response)
      user = current_user(response)
      halt 403 unless user&.admin
    end
  end
end
