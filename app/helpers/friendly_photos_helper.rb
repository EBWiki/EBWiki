# frozen_string_literal: true

module FriendlyPhotosHelper
  def friendly_photo_source_link(candidate)
    return unless FriendlyPhotos::WikimediaClient.allowed_page_url?(candidate.page_url)

    link_to 'Source page', candidate.page_url, target: '_blank', rel: 'noopener'
  end

  def pending_friendly_photo_count(this_case)
    this_case.photo_candidates.count { |candidate| candidate.pending? && candidate.friendly? }
  end
end
