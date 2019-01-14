class AddNameIndexToStates < ActiveRecord::Migration
  def change
    add_index :states, :name
  end
end
