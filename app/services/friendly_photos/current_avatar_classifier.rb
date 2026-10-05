# frozen_string_literal: true

module FriendlyPhotos
  # Marks existing case avatars as mugshots when the filename looks like one.
  class CurrentAvatarClassifier
    include Service

    def call(dry_run: false)
      counts = { would_mark_mugshot: 0, unchanged: 0 }
      updated = 0

      Case.find_each do |this_case|
        bucket = classification_bucket(this_case)
        next if bucket.nil?

        if bucket == :mugshot
          counts[:would_mark_mugshot] += 1
          unless dry_run
            # rubocop:disable Rails/SkipsModelValidations -- metadata-only classification
            this_case.update_column(:avatar_kind, 'mugshot')
            # rubocop:enable Rails/SkipsModelValidations
            updated += 1
          end
        else
          counts[:unchanged] += 1
        end
      end

      return counts if dry_run

      updated
    end

    private

    def classification_bucket(this_case)
      filename = this_case[:avatar]
      return nil if filename.blank?
      return :unchanged unless this_case.unclassified?

      MugshotClassifier.call(text: filename).likely_mugshot ? :mugshot : :unchanged
    end
  end
end
