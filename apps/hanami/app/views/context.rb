# auto_register: false
# frozen_string_literal: true

module EbWiki
  module Views
    class Context < Hanami::View::Context
      def current_user
        return unless request?

        user_id = request.session[:user_id]
        return unless user_id

        @current_user ||= Hanami.app["repos.user_repo"].by_id(user_id)
      end
    end
  end
end
