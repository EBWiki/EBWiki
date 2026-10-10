# frozen_string_literal: true

module EbWiki
  module Actions
    module Users
      class Show < EbWiki::Action
        include Deps["repos.user_repo"]

        def handle(request, response)
          user = user_repo.find_profile(request.params[:id])
          halt 404 unless user

          response.render(
            view,
            profile: user,
            followed_cases: user_repo.followed_cases(user.id)
          )
        end
      end
    end
  end
end
