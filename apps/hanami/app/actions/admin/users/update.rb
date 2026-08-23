# frozen_string_literal: true

module EbWiki
  module Actions
    module Admin
      module Users
        class Update < EbWiki::Action
          include Deps["repos.user_repo"]

          def handle(request, response)
            require_user!(response)
            return if response.status == 302

            require_admin!(response)
            return if response.status == 403

            user_repo.update_roles(
              request.params[:id],
              admin: request.params[:admin] == "1",
              analyst: request.params[:analyst] == "1"
            )
            response.redirect_to "/admin/users"
          end
        end
      end
    end
  end
end
