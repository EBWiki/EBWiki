# frozen_string_literal: true

module EbWiki
  module Actions
    module Confirmations
      class Show < EbWiki::Action
        include Deps["repos.user_repo"]

        def handle(request, response)
          user = user_repo.confirm(request.params[:confirmation_token])
          if user
            sign_in!(request, response, user)
            response.redirect_to "/"
          else
            response.status = 422
            response.render view, error: "This confirmation link is invalid or has already been used."
          end
        end
      end
    end
  end
end
