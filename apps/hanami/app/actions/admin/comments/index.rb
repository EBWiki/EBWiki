# frozen_string_literal: true

module EbWiki
  module Actions
    module Admin
      module Comments
        class Index < EbWiki::Action
          include Deps["repos.case_repo"]

          def handle(_request, response)
            require_user!(response)
            return if response.status == 302

            require_admin!(response)
            return if response.status == 403

            comments = case_repo.recent_comments
            slugs = comments.each_with_object({}) do |comment, hash|
              hash[comment.id] = case_repo.comment_case_slug(comment)
            end
            response.render(
              view,
              comments: comments,
              authors: case_repo.users_by_id(comments.map(&:user_id)),
              case_slugs: slugs
            )
          end
        end
      end
    end
  end
end
