# frozen_string_literal: true

module EbWiki
  module Actions
    module Cases
      class Destroy < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          require_admin!(response)
          return if response.status == 403

          slug = request.params[:case_slug]
          followers_page = case_repo.followers_for(slug)
          halt 404 unless followers_page

          record = case_repo.destroy(slug)
          halt 404 unless record

          EbWiki::Mailer.send_deletion_email(
            users: followers_page.fetch(:followers),
            this_case: record
          )

          response.redirect_to "/"
        end
      end
    end
  end
end
