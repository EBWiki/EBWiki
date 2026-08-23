# frozen_string_literal: true

module EbWiki
  module Actions
    module Comments
      class Create < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          page = case_repo.find_page(request.params[:case_id])
          halt 404 unless page

          content = request.params[:content].to_s.strip
          if content.empty?
            response.redirect_to "/cases/#{page[:record].slug}"
            return
          end

          case_repo.add_comment(
            case_id: page[:record].id,
            user_id: current_user(response).id,
            content: content
          )
          response.redirect_to "/cases/#{page[:record].slug}"
        end
      end
    end
  end
end
