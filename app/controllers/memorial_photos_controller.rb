# frozen_string_literal: true

# Staging-only browse UI for link-only case photos (Mapping Police Violence and similar).
class MemorialPhotosController < ApplicationController
  before_action :ensure_memorial_photos_enabled!

  def index
    @filters = MemorialPhotos::FilterParams.from_request(params)
    @agencies = Agency.order(:name)
    @cases = MemorialPhotoGridQuery.new(filters: @filters).call
    @query_failed = false
  rescue MemorialPhotos::QueryError
    @cases = Case.none.page(1)
    @query_failed = true
    @agencies = Agency.order(:name)
  end

  private

  def ensure_memorial_photos_enabled!
    head :not_found unless MemorialPhotos.enabled?
  end
end
