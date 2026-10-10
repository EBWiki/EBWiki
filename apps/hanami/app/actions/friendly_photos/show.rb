# frozen_string_literal: true

module EbWiki
  module Actions
    module FriendlyPhotos
      class Show < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          page = case_repo.find_page(request.params[:id])
          halt 404 unless page

          response.render(
            view,
            case_page: page,
            attach_notice: request.session.delete(:attach_notice),
            attach_error: request.session.delete(:attach_error)
          )
        end
      end
    end
  end
end
