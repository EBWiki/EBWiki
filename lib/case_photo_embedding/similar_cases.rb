# frozen_string_literal: true

module CasePhotoEmbedding
  # Nearest-neighbor search over whole-image SigLIP vectors for shown case photos.
  module SimilarCases
    module_function

    def ranked_by_embedding(embedding, limit: 10)
      return Case.none if embedding.blank?

      Case.with_shown_photo
          .where.not(photo_embedding: nil)
          .nearest_neighbors(:photo_embedding, embedding, distance: 'cosine')
          .limit(limit)
    end

    def more_like_this(case_record, limit: 6)
      return Case.none if case_record.photo_embedding.blank?

      ranked_by_embedding(case_record.photo_embedding, limit: limit + 1)
        .where.not(id: case_record.id)
        .limit(limit)
    end
  end
end
