# frozen_string_literal: true

class CreateCasePhotoChangeRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :case_photo_change_requests do |t|
      t.references :case, null: false, foreign_key: true
      t.string :request_type, null: false
      t.text :message
      t.string :requester_contact
      t.string :replacement_photo
      t.string :status, null: false, default: 'pending'
      t.datetime :resolved_at
      t.datetime :contact_purge_after

      t.timestamps
    end

    add_index :case_photo_change_requests, :status

    execute <<~SQL.squish
      ALTER TABLE case_photo_change_requests
      ADD CONSTRAINT case_photo_change_requests_request_type_allowed
      CHECK (request_type IN ('remove', 'replace'))
    SQL

    execute <<~SQL.squish
      ALTER TABLE case_photo_change_requests
      ADD CONSTRAINT case_photo_change_requests_status_allowed
      CHECK (status IN ('pending', 'resolved'))
    SQL
  end
end
