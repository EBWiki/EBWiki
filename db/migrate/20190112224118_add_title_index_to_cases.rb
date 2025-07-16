class AddTitleIndexToCases < ActiveRecord::Migration[5.2]
  def change
    add_index :cases, :title
  end
end
