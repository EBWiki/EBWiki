# frozen_string_literal: true

module EbWiki
  module Actions
    module Organizations
      class New < EbWiki::Action
        def handle(_request, response)
          require_user!(response)
          return if response.status == 302

          response.render(view)
        end
      end
    end
  end
end
