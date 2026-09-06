# frozen_string_literal: true

module FriendlyPhotosHelper
  def friendly_photo_source_link(candidate)
    return unless FriendlyPhotos::SourcePolicy.allowed_page_url?(candidate.page_url)

    link_to 'Source page', candidate.page_url, target: '_blank', rel: 'noopener'
  end

  def friendly_photo_license_label(candidate)
    text = candidate.license.presence || 'License unknown'
    return text if candidate.license_url.blank?
    return text unless FriendlyPhotos::SourcePolicy.allowed_page_url?(candidate.license_url)

    link_to text, candidate.license_url, target: '_blank', rel: 'noopener'
  end

  def pending_friendly_photo_count(this_case)
    this_case.photo_candidates.count { |candidate| candidate.pending? && candidate.friendly? }
  end

  def friendly_photos_search_mode_label
    if FriendlyPhotos::WikimediaClient.stubbed?
      'stubbed (E2E fixtures only)'
    else
      'live Wikimedia + Openverse'
    end
  end
end
