# frozen_string_literal: true

# Photo classification and Wikimedia candidate lookup for case subjects.
module CaseFriendlyPhoto
  extend ActiveSupport::Concern

  included do
    has_many :photo_candidates, dependent: :destroy

    enum :avatar_kind, {
      unclassified: 'unclassified',
      portrait: 'portrait',
      mugshot: 'mugshot',
      other: 'other'
    }

    scope :needing_friendly_photo, lambda {
      where(avatar_kind: %w[unclassified mugshot]).or(where(avatar: [nil, '']))
    }
  end

  def subject_display_name
    subjects.first&.name.presence || title
  end

  def missing_avatar?
    self[:avatar].blank?
  end

  def needs_friendly_photo?
    missing_avatar? || unclassified? || mugshot?
  end
end
