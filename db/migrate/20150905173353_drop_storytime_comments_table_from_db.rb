class DropStorytimeCommentsTableFromDb < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.table_exists? :storytime_comments
      drop_table :storytime_comments
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
