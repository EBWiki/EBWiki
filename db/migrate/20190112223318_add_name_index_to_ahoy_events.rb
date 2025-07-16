class AddNameIndexToAhoyEvents < ActiveRecord::Migration[5.2]
  def change
    add_index :ahoy_events, :name
  end
end
