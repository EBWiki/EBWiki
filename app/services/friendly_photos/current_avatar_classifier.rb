# frozen_string_literal: true

module FriendlyPhotos
  # Marks existing case avatars as mugshots when the filename looks like one.
  class CurrentAvatarClassifier
    include Service

    def call
      updated = 0
      Case.find_each do |this_case|
        next unless classifiable?(this_case)

        # rubocop:disable Rails/SkipsModelValidations -- metadata-only classification
        this_case.update_column(:avatar_kind, 'mugshot')
        # rubocop:enable Rails/SkipsModelValidations
        updated += 1
      end
      updated
    end

    private

    def classifiable?(this_case)
      filename = this_case[:avatar]
      return false if filename.blank?
      return false unless this_case.unclassified?

      MugshotClassifier.call(text: filename).likely_mugshot
    end
  end
end
