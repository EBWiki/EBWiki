# frozen_string_literal: true

module EbWiki
  module Actions
    module Sessions
      class Create < EbWiki::Action
        include Deps["repos.user_repo"]

        def handle(request, response)
          user = user_repo.authenticate(
            email: request.params[:email],
            password: request.params[:password]
          )

          if user
            request.session[:user_id] = user.id
            response.redirect_to "/"
          else
            response.status = 401
            response.render(view, error: "Invalid email or password, or the account is unconfirmed.")
          end
        end
      end
    end
  end
end
