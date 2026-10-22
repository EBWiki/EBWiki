# frozen_string_literal: true

module CasePhotoRequestsFeature
  extend ActiveSupport::Concern

  included do
    before_action :ensure_case_photo_requests_enabled!
  end

  private

  def ensure_case_photo_requests_enabled!
    return if CasePhotoRequests.enabled?

    raise ActionController::RoutingError, 'Not Found'
  end
end
