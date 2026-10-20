# frozen_string_literal: true

class PhotoFinderJob < ApplicationJob
  queue_as :default

  def perform(case_id)
    case_record = Case.includes(:subjects, :state).find_by(id: case_id)
    return unless case_record
    return if case_record.avatar?

    PhotoFinder::Search.new(case_record).call.each do |finder_candidate|
      CasePhotoCandidate.create_from_photo_finder_candidate!(case_record, finder_candidate)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      next
    end
  end
end
