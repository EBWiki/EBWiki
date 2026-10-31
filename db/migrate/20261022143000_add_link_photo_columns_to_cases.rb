# frozen_string_literal: true

class AddLinkPhotoColumnsToCases < ActiveRecord::Migration[8.1]
  def up
    change_table :cases, bulk: true do |t|
      t.string :photo_url
      t.string :photo_source_url
      t.string :photo_credit
      t.string :photo_status
    end

    execute <<~SQL.squish
      ALTER TABLE cases
      ADD CONSTRAINT cases_photo_status_allowed
      CHECK (photo_status IS NULL OR photo_status IN ('shown', 'hidden', 'removed'))
    SQL
  end

  def down
    execute 'ALTER TABLE cases DROP CONSTRAINT IF EXISTS cases_photo_status_allowed'

    change_table :cases, bulk: true do |t|
      t.remove :photo_url
      t.remove :photo_source_url
      t.remove :photo_credit
      t.remove :photo_status
    end
  end
end
