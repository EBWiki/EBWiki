# frozen_string_literal: true

module EbWiki
  module Actions
    module Agencies
      class Show < EbWiki::Action
        include Deps["repos.agency_repo"]

        def handle(request, response)
          page = agency_repo.find_page(request.params[:id])
          halt 404 unless page

          response.render(view, agency_page: page)
        end
      end
    end
  end
end
