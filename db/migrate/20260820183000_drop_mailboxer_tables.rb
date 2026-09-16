# frozen_string_literal: true

class DropMailboxerTables < ActiveRecord::Migration[8.1]
  def up
    drop_mailboxer_foreign_keys
    drop_table :mailboxer_receipts, if_exists: true
    drop_table :mailboxer_notifications, if_exists: true
    drop_table :mailboxer_conversation_opt_outs, if_exists: true
    drop_table :mailboxer_conversations, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def drop_mailboxer_foreign_keys
    {
      mailboxer_receipts: 'receipts_on_notification_id',
      mailboxer_notifications: 'notifications_on_conversation_id',
      mailboxer_conversation_opt_outs: 'mb_opt_outs_on_conversations_id'
    }.each do |table, name|
      next unless table_exists?(table) && foreign_key_exists?(table, name: name)

      remove_foreign_key table, name: name
    end
  end
end
