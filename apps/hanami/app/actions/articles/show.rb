# frozen_string_literal: true

module EbWiki
  module Actions
    module Articles
      class Show < EbWiki::Action
        def handle(request, response)
          response.redirect_to "/cases/#{request.params[:slug]}", status: 301
        end
      end
    end
  end
end
