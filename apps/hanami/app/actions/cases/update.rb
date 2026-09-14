# frozen_string_literal: true

module EbWiki
  module Actions
    module Cases
      class Update < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          attrs = Create.new.send(:case_attrs, request.params)
          errors = Create.new.send(:validate_case, attrs)
          if errors.any?
            page = case_repo.find_page(request.params[:id])
            response.status = 422
            response.render view, case_page: page, errors: errors, values: attrs
            return
          end

          record = case_repo.update_with_children(request.params[:id], attrs, user: current_user(response))
          halt 404 unless record

          followers = case_repo.followers_for(record.slug)&.fetch(:followers, [])
          EbWiki::Mailer.send_followers_email(
            users: followers,
            this_case: record,
            editor_name: current_user(response)&.name,
            comment: attrs[:summary],
            base_url: public_base_url(request)
          )

          response.redirect_to "/cases/#{record.slug}"
        end
      end
    end
  end
end
