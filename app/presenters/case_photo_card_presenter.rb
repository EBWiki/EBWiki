# frozen_string_literal: true

# Renders a case link photo or a neutral name card without exposing hidden image URLs.
class CasePhotoCardPresenter
  def initialize(case_record)
    @case_record = case_record
  end

  def display_name
    case_record.title
  end

  def alt_text
    "Photo of #{display_name}"
  end

  def feature_active?
    CasePhotoRequests.enabled?
  end

  def suppress_all_images?
    feature_active? && (case_record.photo_hidden? || case_record.photo_removed?)
  end

  def render_photo?
    feature_active? &&
      !suppress_all_images? &&
      case_record.photo_shown? &&
      case_record.photo_url.present?
  end

  def name_card?
    return false unless feature_active?

    suppress_all_images? || (!render_photo? && case_record.photo_url.present?)
  end

  def render_legacy_avatar?
    return false unless feature_active?
    return false if suppress_all_images? || name_card? || render_photo?

    case_record.avatar?
  end

  def render_default_icon?
    !render_photo? && !name_card? && !render_legacy_avatar?
  end

  private

  attr_reader :case_record
end
