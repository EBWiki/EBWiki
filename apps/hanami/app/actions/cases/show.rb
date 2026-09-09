# frozen_string_literal: true

module EbWiki
  module Actions
    module Cases
      class Show < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          slug = request.params[:id]
          page = case_repo.find_page(slug)
          halt 404 unless page

          viewer = current_user(response)
          following = viewer && case_repo.following?(case_id: page[:record].id, user_id: viewer.id)
          response.render(view, case_page: page, viewer: viewer, following: following)
        end
      end
    end
  end
end
