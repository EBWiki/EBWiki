# frozen_string_literal: true

class DropMugshotUseFromFriendlyPhotos < ActiveRecord::Migration[8.1]
  def up
    remove_column :photo_candidates, :likely_mugshot, :boolean
    execute <<~SQL.squish
      UPDATE cases SET avatar_kind = 'other'
      WHERE avatar_kind = 'mugshot'
    SQL
  end

  def down
    add_column :photo_candidates, :likely_mugshot, :boolean, default: false, null: false
  end
end
