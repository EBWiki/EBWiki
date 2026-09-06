# frozen_string_literal: true

# Historic review dumps omit `sessions` while schema_migrations may still list
# AddSessionsTable, leaving deploy_prepare migrations a no-op and the app 500ing
# on session store (ApplicationController#store_user_location!).
module ReviewSessionsTable
  module_function

  def ensure!
    conn = ActiveRecord::Base.connection
    create_table_if_missing(conn)
    ensure_indexes(conn)
  end

  def create_table_if_missing(conn)
    return if conn.table_exists?(:sessions)

    conn.create_table :sessions do |t|
      t.string :session_id, null: false
      t.text :data
      t.timestamps
    end
  end

  def ensure_indexes(conn)
    unless conn.index_exists?(:sessions, :session_id)
      conn.add_index :sessions, :session_id, unique: true
    end
    return if conn.index_exists?(:sessions, :updated_at)

    conn.add_index :sessions, :updated_at
  end
end
