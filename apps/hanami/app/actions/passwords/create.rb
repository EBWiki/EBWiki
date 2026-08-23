# frozen_string_literal: true

module EbWiki
  module Actions
    module Passwords
      class Create < EbWiki::Action
        include Deps["repos.user_repo"]

        def handle(request, response)
          user_repo.request_password_reset(request.params[:email])
          response.redirect_to "/login?reset=1"
        end
      end
    end
  end
end
