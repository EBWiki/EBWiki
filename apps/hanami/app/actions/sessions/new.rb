# frozen_string_literal: true

module EbWiki
  module Actions
    module Sessions
      class New < EbWiki::Action
        def handle(request, response)
          response.render view, error: nil, notice: notice_for(request)
        end

        private

        def notice_for(request)
          if request.params[:registered].to_s == "1"
            "Account created. Check your email for a confirmation link."
          elsif request.params[:reset].to_s == "1"
            "If that email is registered, a password reset link is on its way."
          end
        end
      end
    end
  end
end
