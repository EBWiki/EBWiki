# frozen_string_literal: true

module EbWiki
  module Actions
    module Cases
      class Create < EbWiki::Action
        include Deps["repos.case_repo"]

        def handle(request, response)
          require_user!(response)
          return if response.status == 302

          attrs = case_attrs(request.params)
          errors = validate_case(attrs)
          if errors.any?
            response.status = 422
            response.render view, errors: errors, values: attrs
            return
          end

          record = case_repo.create_with_children(attrs, user: current_user(response))
          response.redirect_to "/cases/#{record.slug}"
        end

        private

        def case_attrs(params)
          raw = params[:case] || params
          {
            title: raw[:title],
            date: raw[:date],
            city: raw[:city],
            address: raw[:address],
            zipcode: raw[:zipcode],
            state_id: raw[:state_id],
            overview: raw[:overview],
            litigation: raw[:litigation],
            community_action: raw[:community_action],
            blurb: raw[:blurb],
            summary: raw[:summary],
            video_url: raw[:video_url],
            cause_of_death: raw[:cause_of_death],
            subjects: Array(raw[:subjects]),
            links: Array(raw[:links]),
            agency_ids: Array(raw[:agency_ids])
          }
        end

        def validate_case(attrs)
          errors = []
          errors << "Title is required" if attrs[:title].to_s.strip.empty?
          errors << "City is required" if attrs[:city].to_s.strip.empty?
          errors << "State is required" if attrs[:state_id].to_s.strip.empty?
          errors << "Overview is required" if attrs[:overview].to_s.strip.empty?
          errors << "Blurb is required" if attrs[:blurb].to_s.strip.empty?
          errors << "Edit summary is required" if attrs[:summary].to_s.strip.empty?
          errors << "Date is required" if attrs[:date].to_s.strip.empty?
          errors << "At least one subject is required" if Array(attrs[:subjects]).none? { |s| s[:name].to_s.strip != "" }
          errors
        end
      end
    end
  end
end
