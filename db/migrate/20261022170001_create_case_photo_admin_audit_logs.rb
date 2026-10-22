# frozen_string_literal: true

class CreateCasePhotoAdminAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :case_photo_admin_audit_logs do |t|
      t.references :case, null: false, foreign_key: true, index: true
      t.string :action, null: false
      t.datetime :created_at, null: false
    end

    add_index :case_photo_admin_audit_logs, :created_at
  end
end
