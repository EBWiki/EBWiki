# frozen_string_literal: true

module EbWiki
  module Actions
    module Organizations
      class Show < EbWiki::Action
        include Deps["repos.organization_repo"]

        def handle(request, response)
          record = organization_repo.by_id(request.params[:id])
          halt 404 unless record

          response.render(view, organization: record)
        end
      end
    end
  end
end
