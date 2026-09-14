# frozen_string_literal: true

module EbWiki
  module Actions
    module Cases
      class Revert < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          slug = request.params[:case_slug]
          result = case_repo.revert_to_version(
            slug,
            request.params[:version_id],
            user: current_user(response)
          )

          if result == :no_snapshot
            response.redirect_to "/cases/#{slug}/history"
            return
          end

          halt 404 unless result
          response.redirect_to "/cases/#{result.slug}"
        end
      end
    end
  end
end
