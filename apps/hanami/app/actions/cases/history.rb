# frozen_string_literal: true

module EbWiki
  module Actions
    module Cases
      class History < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          page = case_repo.history_for(request.params[:case_slug])
          halt 404 unless page

          response.render(view, history_page: page)
        end
      end
    end
  end
end
