# frozen_string_literal: true

module EbWiki
  module Actions
    module Passwords
      class Edit < EbWiki::Action
        def handle(request, response)
          token = request.params[:reset_password_token].to_s
          halt 404 if token.empty?

          response.render(view, token: token)
        end
      end
    end
  end
end
