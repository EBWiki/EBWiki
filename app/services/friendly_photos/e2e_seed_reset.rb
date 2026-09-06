# frozen_string_literal: true

module FriendlyPhotos
  # Removes prior e2e fixtures. On a large review dump, keep the case rows.
  class E2eSeedReset
    include Service

    def call
      if Case.count > E2eSeed::SUBSTANTIAL_CASE_THRESHOLD
        clear_seed_associations
      else
        ReviewDbConnection.with_pooler_retry { delete_seed_records }
      end
    end

    private

    def seed_case_ids
      Case.where(slug: E2eSeed::SLUGS).pluck(:id)
    end

    def delete_seed_records
      ids = seed_case_ids
      return if ids.empty?

      PhotoCandidate.where(case_id: ids).delete_all
      Subject.where(case_id: ids).delete_all
      Case.where(id: ids).delete_all
      User.where(email: E2eSeed::EMAIL).delete_all
    end

    def clear_seed_associations
      ids = seed_case_ids
      return if ids.empty?

      ReviewDbConnection.with_pooler_retry do
        PhotoCandidate.where(case_id: ids).delete_all
        Subject.where(case_id: ids).delete_all
      end
    end
  end
end
