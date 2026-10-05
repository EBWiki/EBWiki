# frozen_string_literal: true

class AddFriendlyPhotoSearch < ActiveRecord::Migration[8.1]
  def change
    add_column :cases, :avatar_kind, :string, default: 'unclassified', null: false
    add_index :cases, :avatar_kind

    create_table :photo_candidates do |t|
      t.references :case, null: false, foreign_key: true, type: :integer
      t.string :subject_name, null: false
      t.string :source, null: false
      t.string :title
      t.string :image_url, null: false
      t.string :page_url
      t.string :license
      t.string :author
      t.integer :score, default: 0, null: false
      t.string :status, default: 'pending', null: false
      t.boolean :likely_mugshot, default: false, null: false
      t.text :notes
      t.timestamps
    end

    add_index :photo_candidates, %i[case_id image_url], unique: true
    add_index :photo_candidates, :status
  end
end
