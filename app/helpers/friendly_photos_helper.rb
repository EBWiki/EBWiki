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
    this_case.photo_candidates.count(&:applyable?)
  end

  def friendly_photos_search_mode_label
    if FriendlyPhotos::WikimediaClient.stubbed?
      'stubbed (E2E fixtures only)'
    else
      'live Wikimedia + Openverse'
    end
  end

  def friendly_photo_ai_badge(candidate)
    planner = candidate.planner_ai_used? ? 'planner: AI' : 'planner: no'
    vision = if candidate.vision_ai_used?
               'vision: AI'
             elsif candidate.vision_failed?
               'vision: failed'
             else
               'vision: no'
             end
    [planner, vision].join(' · ')
  end

  def friendly_photo_last_search_ai_label(last_search_ai)
    return unless last_search_ai

    planner = last_search_ai[:planner_ai_used] ? 'planner ran' : 'planner did NOT run'
    vision = "vision verified #{last_search_ai[:vision_ai_used_count]}"
    parts = ["Last search — #{planner}", vision]
    parts << last_search_ai[:warnings].join(' ') if last_search_ai[:warnings].present?
    parts.join(' · ')
  end

  def candidate_applyable?(candidate)
    candidate.applyable?
  end
end
