# frozen_string_literal: true

module EbWiki
  module Actions
    module Passwords
      class Create < EbWiki::Action
        include Deps["repos.user_repo"]

        def handle(request, response)
          user = user_repo.request_password_reset(request.params[:email])
          if user
            EbWiki::Mailer.reset_password_instructions(
              user: user,
              token: user.reset_password_token,
              base_url: public_base_url(request)
            )
          end
          response.redirect_to "/login?reset=1"
        end
      end
    end
  end
end
