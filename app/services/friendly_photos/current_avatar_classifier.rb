# frozen_string_literal: true

module FriendlyPhotos
  # Marks existing case avatars as mugshots when the filename looks like one.
  class CurrentAvatarClassifier
    include Service

    def call(dry_run: false)
      counts = { would_mark_mugshot: 0, unchanged: 0 }
      updated = 0
      Case.find_each { |this_case| updated += process_case(this_case, counts, dry_run) }
      dry_run ? counts : updated
    end

    private

    def process_case(this_case, counts, dry_run)
      bucket = classification_bucket(this_case)
      return 0 if bucket.nil?

      if bucket == :mugshot
        counts[:would_mark_mugshot] += 1
        persist_mugshot!(this_case) unless dry_run
        dry_run ? 0 : 1
      else
        counts[:unchanged] += 1
        0
      end
    end

    def persist_mugshot!(this_case)
      # rubocop:disable Rails/SkipsModelValidations -- metadata-only classification
      this_case.update_column(:avatar_kind, 'mugshot')
      # rubocop:enable Rails/SkipsModelValidations
    end

    def classification_bucket(this_case)
      filename = this_case[:avatar]
      return nil if filename.blank?
      return :unchanged unless this_case.unclassified?

      MugshotClassifier.call(text: filename).likely_mugshot ? :mugshot : :unchanged
    end
  end
end
