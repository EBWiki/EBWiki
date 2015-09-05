class DropStorytimeCommentsTableFromDb < ActiveRecord::Migration
  def up
    drop_table :storytime_comments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
