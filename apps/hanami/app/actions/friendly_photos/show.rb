# frozen_string_literal: true

module EbWiki
  module Actions
    module FriendlyPhotos
      class Show < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          page = case_repo.find_page(request.params[:id])
          halt 404 unless page

          response.render(view, case_page: page)
        end
      end
    end
  end
end
