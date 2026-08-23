# frozen_string_literal: true

module EbWiki
  module Actions
    module Cases
      class Index < EbWiki::Action
        def handle(request, response)
          response.render(view, page: request.params[:page] || 1)
        end
      end
    end
  end
end
