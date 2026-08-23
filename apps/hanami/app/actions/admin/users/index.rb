# frozen_string_literal: true

module EbWiki
  module Actions
    module Admin
      module Users
        class Index < EbWiki::Action
          include Deps["repos.user_repo"]

          def handle(request, response)
            require_user!(response)
            return if response.status == 302

            require_admin!(response)
            return if response.status == 403

            response.render(view, query: request.params[:query].to_s, users: user_repo.search_by_email(request.params[:query]))
          end
        end
      end
    end
  end
end
