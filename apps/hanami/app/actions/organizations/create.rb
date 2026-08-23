# frozen_string_literal: true

module EbWiki
  module Actions
    module Organizations
      class Create < EbWiki::Action
        include Deps["repos.organization_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          attrs = org_attrs(request.params)
          if attrs[:name].to_s.strip.empty?
            response.status = 422
            response.render view, errors: ["Name is required"], values: attrs
            return
          end

          record = organization_repo.create(attrs)
          response.redirect_to "/organizations/#{record.id}"
        end

        private

        def org_attrs(params)
          raw = params[:organization] || params
          {
            name: raw[:name],
            description: raw[:description],
            website: raw[:website],
            telephone: raw[:telephone]
          }
        end
      end
    end
  end
end
