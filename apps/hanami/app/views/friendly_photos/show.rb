# frozen_string_literal: true

require "eb_wiki/friendly_photos/candidate_search"

module EbWiki
  module Views
    module FriendlyPhotos
      class Show < EbWiki::View
        expose :this_case do |case_page:|
          case_page.fetch(:record)
        end

        expose :subjects do |case_page:|
          case_page.fetch(:subjects)
        end

        expose :search_name do |case_page:|
          name = case_page.fetch(:subjects).first&.name.to_s.strip
          name.empty? ? case_page.fetch(:record).title : name
        end

        expose :candidates do |case_page:|
          record = case_page.fetch(:record)
          name = case_page.fetch(:subjects).first&.name.to_s.strip
          name = record.title if name.empty?
          EbWiki::FriendlyPhotos::CandidateSearch.new(name: name, city: record.city).call
        end

        expose :attach_notice do |attach_notice: nil, **|
          attach_notice
        end

        expose :attach_error do |attach_error: nil, **|
          attach_error
        end
      end
    end
  end
end
