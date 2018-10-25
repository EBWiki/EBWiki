class AddNotNilConstraintToCases < ActiveRecord::Migration
  def change
    change_column :cases, :city, :string, null: false
  end
end
