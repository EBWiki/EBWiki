# frozen_string_literal: true

# Photo classification and Wikimedia candidate lookup for case subjects.
module CaseFriendlyPhoto
  extend ActiveSupport::Concern

  AVATAR_KIND_LABELS = {
    'unclassified' => 'Not yet reviewed',
    'portrait' => 'Profile picture',
    'mugshot' => 'Needs a healthier photo',
    'other' => 'Other'
  }.freeze

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

  class_methods do
    def avatar_kind_label(kind)
      CaseFriendlyPhoto::AVATAR_KIND_LABELS.fetch(kind.to_s, kind.to_s.humanize)
    end

    def avatar_kind_options
      avatar_kinds.keys.map { |kind| [avatar_kind_label(kind), kind] }
    end
  end

  def subject_display_name
    subjects.first&.name.presence || title
  end

  def avatar_kind_label
    self.class.avatar_kind_label(avatar_kind)
  end

  def missing_avatar?
    self[:avatar].blank?
  end

  def needs_friendly_photo?
    missing_avatar? || unclassified? || mugshot?
  end
end
