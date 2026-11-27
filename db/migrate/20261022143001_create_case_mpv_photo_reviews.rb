# frozen_string_literal: true

class CreateCaseMpvPhotoReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :case_mpv_photo_reviews do |t|
      t.references :case, foreign_key: { on_delete: :cascade }
      t.string :mpv_name, null: false
      t.date :mpv_date
      t.string :mpv_state, null: false
      t.string :victim_image_url, null: false
      t.string :photo_source_url
      t.string :photo_credit
      t.text :match_detail, null: false
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end

    add_index :case_mpv_photo_reviews, :status
  end
end
