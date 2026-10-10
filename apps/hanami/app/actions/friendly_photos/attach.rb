# frozen_string_literal: true

require "eb_wiki/friendly_photos/apply_candidate"
require "eb_wiki/friendly_photos/hit"

module EbWiki
  module Actions
    module FriendlyPhotos
      class Attach < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          slug = request.params[:id].to_s
          page = case_repo.find_page(slug)
          halt 404 unless page

          hit = hit_from_params(request.params)
          result = EbWiki::FriendlyPhotos::ApplyCandidate.new.call(hit: hit)

          if result.success
            case_repo.apply_reviewed_photo_url(
              slug: slug,
              image_url: hit.image_url,
              comment: "Applied reviewed profile picture '#{hit.title}' (#{hit.license}).",
              user: current_user(response)
            )
            request.session[:attach_notice] = "Applied the selected profile picture to this case."
          else
            request.session[:attach_error] = result.error
          end

          response.redirect_to "/friendly_photos/#{slug}"
        end

        private

        def hit_from_params(params)
          EbWiki::FriendlyPhotos::Hit.new(
            source: params[:source].to_s,
            title: params[:title].to_s,
            image_url: params[:image_url].to_s,
            page_url: params[:page_url].to_s,
            license: params[:license].to_s,
            author: params[:author].to_s,
            description: params[:description].to_s,
            likely_mugshot: params[:likely_mugshot].to_s == "1"
          )
        end
      end
    end
  end
end
