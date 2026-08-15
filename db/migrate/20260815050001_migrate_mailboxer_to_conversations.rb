# frozen_string_literal: true

class MigrateMailboxerToConversations < ActiveRecord::Migration[8.1]
  def up
    return unless table_exists?(:mailboxer_conversations)

    say_with_time 'Copy mailboxer conversations' do
      execute <<~SQL.squish
        INSERT INTO conversations (id, subject, created_at, updated_at)
        SELECT id, COALESCE(subject, 'Conversation'), created_at, updated_at
        FROM mailboxer_conversations
        ON CONFLICT (id) DO NOTHING
      SQL
    end

    say_with_time 'Copy mailboxer messages' do
      execute <<~SQL.squish
        INSERT INTO messages (conversation_id, sender_id, body, created_at, updated_at)
        SELECT n.conversation_id,
               n.sender_id,
               COALESCE(n.body, ''),
               n.created_at,
               n.updated_at
        FROM mailboxer_notifications n
        WHERE n.conversation_id IS NOT NULL
          AND n.sender_type = 'User'
          AND n.sender_id IS NOT NULL
      SQL
    end

    say_with_time 'Copy mailboxer participants' do
      execute <<~SQL.squish
        INSERT INTO conversation_participants (conversation_id, user_id, trashed, read_at, created_at, updated_at)
        SELECT n.conversation_id,
               r.receiver_id,
               COALESCE(r.trashed, false),
               CASE WHEN r.is_read THEN r.updated_at ELSE NULL END,
               r.created_at,
               r.updated_at
        FROM mailboxer_receipts r
        JOIN mailboxer_notifications n ON n.id = r.notification_id
        WHERE r.receiver_type = 'User'
          AND n.conversation_id IS NOT NULL
        ON CONFLICT (conversation_id, user_id) DO NOTHING
      SQL
    end

    execute <<~SQL.squish
      UPDATE conversations c
      SET originator_id = (
        SELECT m.sender_id FROM messages m
        WHERE m.conversation_id = c.id
        ORDER BY m.created_at ASC, m.id ASC
        LIMIT 1
      )
    SQL
  rescue StandardError => e
    say "Skipping mailboxer data copy: #{e.message}"
  end

  def down
    # Irreversible data copy.
  end
end
