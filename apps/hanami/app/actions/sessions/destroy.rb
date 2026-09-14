# frozen_string_literal: true

module EbWiki
  module Actions
    module Sessions
      class Destroy < EbWiki::Action
        def handle(request, response)
          sign_out!(request, response)
          response.redirect_to "/"
        end
      end
    end
  end
end
