# frozen_string_literal: true

module EbWiki
  module Actions
    module Cases
      class Destroy < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          require_admin!(response)
          return if response.status == 403

          record = case_repo.destroy(request.params[:case_slug])
          halt 404 unless record

          response.redirect_to "/"
        end
      end
    end
  end
end
