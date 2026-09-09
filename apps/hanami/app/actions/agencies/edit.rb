# frozen_string_literal: true

module EbWiki
  module Actions
    module Agencies
      class Edit < EbWiki::Action
        include Deps["repos.agency_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          record = agency_repo.by_slug(request.params[:id])
          halt 404 unless record

          response.render(view, agency: record)
        end
      end
    end
  end
end
