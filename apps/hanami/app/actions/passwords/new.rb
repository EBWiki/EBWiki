# frozen_string_literal: true

module EbWiki
  module Actions
    module Passwords
      class New < EbWiki::Action
        def handle(_request, response)
          response.render(view)
        end
      end
    end
  end
end
