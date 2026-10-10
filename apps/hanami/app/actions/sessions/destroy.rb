# frozen_string_literal: true

module EbWiki
  module Actions
    module Sessions
      class Destroy < EbWiki::Action
        def handle(request, response)
          request.session[:user_id] = nil
          response.redirect_to "/"
        end
      end
    end
  end
end
