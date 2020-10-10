class AddNameIndexToAhoyEvents < ActiveRecord::Migration
  def change
    add_index :ahoy_events, :name
  end
end
