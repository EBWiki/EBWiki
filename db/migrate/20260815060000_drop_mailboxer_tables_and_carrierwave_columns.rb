# frozen_string_literal: true

class DropMailboxerTablesAndCarrierwaveColumns < ActiveRecord::Migration[8.1]
  def up
    drop_table :mailboxer_receipts, if_exists: true
    drop_table :mailboxer_notifications, if_exists: true
    drop_table :mailboxer_conversation_opt_outs, if_exists: true
    drop_table :mailboxer_conversations, if_exists: true

    remove_column :cases, :avatar, :string if column_exists?(:cases, :avatar)
    remove_column :cases, :remove_avatar, :boolean if column_exists?(:cases, :remove_avatar)
    return unless column_exists?(:cases, :default_avatar_url)

    remove_column :cases, :default_avatar_url, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
