class AddBlurbToCases < ActiveRecord::Migration
  def change
    add_column :cases, :blurb, :text
  end
end
