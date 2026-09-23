# frozen_string_literal: true

module EbWiki
  module Actions
    module Follows
      class Create < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          page = case_repo.find_page(request.params[:case_id])
          halt 404 unless page

          case_repo.follow(case_id: page[:record].id, user_id: current_user(response).id)
          response.redirect_to "/cases/#{page[:record].slug}"
        end
      end
    end
  end
end
