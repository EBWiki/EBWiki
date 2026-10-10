# frozen_string_literal: true

module EbWiki
  module Actions
    module Maps
      class Index < EbWiki::Action
        def handle(_request, response)
          response.render(view)
        end
      end
    end
  end
end
