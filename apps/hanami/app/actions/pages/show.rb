# frozen_string_literal: true

module EbWiki
  module Actions
    module Pages
      class Show < EbWiki::Action
        PAGES = {
          "/about" => "about",
          "/guidelines" => "guidelines",
          "/instructions" => "instructions",
          "/get-involved" => "get-involved",
          "/how-to-help" => "how-to-help"
        }.freeze

        def handle(request, response)
          page = PAGES[request.path]
          halt 404 unless page

          response.render(view, page: page)
        end
      end
    end
  end
end
