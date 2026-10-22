# frozen_string_literal: true

class AddPhotoEmbeddingToCases < ActiveRecord::Migration[8.1]
  def up
    enable_extension 'vector'

    add_column :cases, :photo_embedding, :vector, limit: 768

    execute <<~SQL.squish
      CREATE INDEX index_cases_on_photo_embedding_hnsw
      ON cases
      USING hnsw (photo_embedding vector_cosine_ops)
      WHERE photo_status = 'shown' AND photo_embedding IS NOT NULL
    SQL
  end

  def down
    execute 'DROP INDEX IF EXISTS index_cases_on_photo_embedding_hnsw'
    remove_column :cases, :photo_embedding
    disable_extension 'vector'
  end
end
