class AddBlurbToCases < ActiveRecord::Migration[5.2]
  def change
    add_column :cases, :blurb, :text
  end
end
