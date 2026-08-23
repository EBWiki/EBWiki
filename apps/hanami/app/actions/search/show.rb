# frozen_string_literal: true

module EbWiki
  module Actions
    module Search
      class Show < EbWiki::Action
        def handle(request, response)
          response.render(
            view,
            query: request.params[:query].to_s,
            page: request.params[:page] || 1,
            state_id: request.params[:state_id]
          )
        end
      end
    end
  end
end
