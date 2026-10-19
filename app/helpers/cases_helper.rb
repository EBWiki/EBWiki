# frozen_string_literal: true

# Helper for case pages.
module CasesHelper
  CASE_PHOTO_VARIANTS = {
    large: [250, 250],
    medium: [150, 150],
    small: [35, 35]
  }.freeze

  def link_to_case_title(this_case, length)
    link_to truncate(this_case.title, length: length), this_case
  end

  def case_photo_url(this_case, size)
    size = size.to_sym

    return unless this_case.photo.attached?

    dimensions = CASE_PHOTO_VARIANTS.fetch(size)
    url_for(this_case.photo.variant(resize_to_fill: dimensions))
  end
end
