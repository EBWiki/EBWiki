# frozen_string_literal: true

module EbWiki
  module Actions
    module Agencies
      class Create < EbWiki::Action
        include Deps["repos.agency_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          attrs = agency_attrs(request.params)
          errors = agency_repo.validation_errors(attrs)
          if errors.any?
            response.status = 422
            response.render view, errors: errors, values: attrs
            return
          end

          record = agency_repo.create(attrs)
          response.redirect_to "/agencies/#{record.slug}"
        end

        private

        def agency_attrs(params)
          raw = params[:agency] || params
          {
            name: raw[:name],
            street_address: raw[:street_address],
            city: raw[:city],
            state_id: raw[:state_id],
            zipcode: raw[:zipcode],
            telephone: raw[:telephone],
            email: raw[:email],
            website: raw[:website],
            jurisdiction: raw[:jurisdiction]
          }
        end

      end
    end
  end
end
