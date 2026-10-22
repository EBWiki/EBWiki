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

  def render_photo?
    case_record.photo_shown? && case_record.photo_url.present?
  end

  def name_card?
    !render_photo? && case_record.photo_url.present?
  end

  private

  attr_reader :case_record
end
