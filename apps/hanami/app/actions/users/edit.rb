# frozen_string_literal: true

module EbWiki
  module Actions
    module Users
      class Edit < EbWiki::Action
        include Deps["repos.user_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          profile = user_repo.find_profile(request.params[:id])
          halt 404 unless profile
          halt 403 unless can_edit?(response, profile)

          response.render(view, profile: profile)
        end

        private

        def can_edit?(response, profile)
          viewer = current_user(response)
          viewer && (viewer.id == profile.id || viewer.admin)
        end
      end
    end
  end
end
