# frozen_string_literal: true

# Whole-image SigLIP embeddings stored in Postgres (pgvector).
module CasePhotoEmbedding
  EMBEDDING_DIMENSIONS = 768
  MODEL_ID = 'google/siglip2-base-patch16-224'
end
