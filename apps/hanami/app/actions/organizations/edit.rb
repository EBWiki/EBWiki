# frozen_string_literal: true

module EbWiki
  module Actions
    module Organizations
      class Edit < EbWiki::Action
        include Deps["repos.organization_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          require_admin!(response)
          return if response.status == 403

          record = organization_repo.by_id(request.params[:id])
          halt 404 unless record

          response.render(view, organization: record)
        end
      end
    end
  end
end
