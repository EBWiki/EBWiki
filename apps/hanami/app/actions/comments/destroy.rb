# frozen_string_literal: true

module EbWiki
  module Actions
    module Comments
      class Destroy < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          comment = case_repo.delete_comment(
            request.params[:id],
            actor: current_user(response)
          )
          halt 403 unless comment

          slug = case_repo.comment_case_slug(comment)
          response.redirect_to slug ? "/cases/#{slug}" : "/"
        end
      end
    end
  end
end
