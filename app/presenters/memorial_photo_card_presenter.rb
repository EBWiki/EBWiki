# frozen_string_literal: true

# Renders one memorial grid card without exposing hidden or removed image URLs.
class MemorialPhotoCardPresenter
  def initialize(case_record, view:)
    @case_record = case_record
    @view = view
  end

  def display_name
    case_record.title
  end

  def alt_text
    "Photo of #{display_name}"
  end

  def render_photo?
    case_record.photo_shown? && case_record.photo_url.present?
  end

  def name_card?
    !render_photo?
  end

  def photo_credit
    case_record.photo_credit.presence
  end

  def photo_source_url
    case_record.photo_source_url.presence
  end

  def case_path
    view.case_path(case_record)
  end

  private

  attr_reader :case_record, :view
end
