# frozen_string_literal: true

class CreateCasePhotoCandidates < ActiveRecord::Migration[8.1]
  def change
    create_table :case_photo_candidates do |t|
      t.references :case, null: false, foreign_key: { on_delete: :cascade }
      t.string :image_url, null: false
      t.string :source_page_url
      t.string :source_name, null: false
      t.string :license_label
      t.string :license_url
      t.string :title
      t.text :description
      t.string :status, null: false, default: 'pending'
      t.datetime :reviewed_at
      t.references :reviewed_by, foreign_key: { to_table: :users, on_delete: :nullify }
      t.text :rejection_reason

      t.timestamps
    end

    add_index :case_photo_candidates, %i[case_id image_url], unique: true
    add_index :case_photo_candidates, :status
  end
end
