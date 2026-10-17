# auto_register: false
# frozen_string_literal: true

require "eb_wiki/rails_session"

module EbWiki
  module Views
    class Context < Hanami::View::Context
      def current_user
        return unless request?
        return @current_user if defined?(@current_user)

        @current_user = EbWiki::RailsSession.current_user(
          request,
          user_repo: Hanami.app["repos.user_repo"],
          session_repo: Hanami.app["repos.session_repo"]
        )
      end
    end
  end
end
