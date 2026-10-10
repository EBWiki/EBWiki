# frozen_string_literal: true

module EbWiki
  module Actions
    module Articles
      class Index < EbWiki::Action
        def handle(_request, response)
          response.redirect_to "/cases", status: 301
        end
      end
    end
  end
end
