# frozen_string_literal: true

module EbWiki
  module Actions
    module Passwords
      class Update < EbWiki::Action
        include Deps["repos.user_repo"]

        def handle(request, response)
          password = request.params[:password].to_s
          token = request.params[:reset_password_token].to_s
          if password.length < 8
            response.status = 422
            response.render view, token: token, error: "Password must be at least 8 characters"
            return
          end

          user = user_repo.reset_password(token: token, password: password)
          halt 404 unless user

          response.redirect_to "/login?password=updated"
        end
      end
    end
  end
end
