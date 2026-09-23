# frozen_string_literal: true

module EbWiki
  module Actions
    module Organizations
      class Update < EbWiki::Action
        include Deps["repos.organization_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          require_admin!(response)
          return if response.status == 403

          record = organization_repo.by_id(request.params[:id])
          halt 404 unless record

          raw = request.params[:organization] || request.params
          attrs = {
            name: raw[:name],
            description: raw[:description],
            website: raw[:website],
            telephone: raw[:telephone]
          }
          if attrs[:name].to_s.strip.empty?
            response.status = 422
            response.render view, organization: record, errors: ["Name is required"], values: attrs
            return
          end

          updated = organization_repo.update(record.id, attrs)
          response.redirect_to "/organizations/#{updated.id}"
        end
      end
    end
  end
end
