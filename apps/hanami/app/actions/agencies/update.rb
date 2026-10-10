# frozen_string_literal: true

module EbWiki
  module Actions
    module Agencies
      class Update < EbWiki::Action
        include Deps["repos.agency_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          record = agency_repo.by_slug(request.params[:id])
          halt 404 unless record

          attrs = {
            name: (request.params[:agency] || request.params)[:name],
            street_address: (request.params[:agency] || request.params)[:street_address],
            city: (request.params[:agency] || request.params)[:city],
            state_id: (request.params[:agency] || request.params)[:state_id],
            zipcode: (request.params[:agency] || request.params)[:zipcode],
            telephone: (request.params[:agency] || request.params)[:telephone],
            email: (request.params[:agency] || request.params)[:email],
            website: (request.params[:agency] || request.params)[:website],
            jurisdiction: (request.params[:agency] || request.params)[:jurisdiction]
          }
          errors = agency_repo.validation_errors(attrs, except_id: record.id)
          if errors.any?
            response.status = 422
            response.render view, agency: record, errors: errors, values: attrs
            return
          end

          updated = agency_repo.update(record.slug, attrs)
          response.redirect_to "/agencies/#{updated.slug}"
        end
      end
    end
  end
end
