class AddTitleIndexToCases < ActiveRecord::Migration
  def change
    add_index :cases, :title
  end
end
