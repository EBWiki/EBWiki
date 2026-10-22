# frozen_string_literal: true

# Staging-only family photo removal and replacement requests (see config/case_photo_requests.yml).
module CasePhotoRequests
  module_function

  def enabled?
    Rails.application.config.x.case_photo_requests.fetch(:enabled, false)
  end
end
