class AddNotNilConstraintToCases < ActiveRecord::Migration[5.2]
  def change
    change_column :cases, :city, :string, null: false
  end
end
