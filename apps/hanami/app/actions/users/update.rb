# frozen_string_literal: true

module EbWiki
  module Actions
    module Users
      class Update < EbWiki::Action
        include Deps["repos.user_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          profile = user_repo.find_profile(request.params[:id])
          halt 404 unless profile

          viewer = current_user(response)
          halt 403 unless viewer
          halt 403 unless viewer.id == profile.id || viewer.admin

          raw = request.params[:user] || request.params
          if raw[:name].to_s.strip.empty?
            response.status = 422
            response.render view, profile: profile, errors: ["Name is required"], values: raw
            return
          end

          updated = user_repo.update_profile(profile.id, name: raw[:name], description: raw[:description])
          response.redirect_to "/users/#{updated.id}"
        end
      end
    end
  end
end
