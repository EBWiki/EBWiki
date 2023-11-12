class AddNameIndexToStates < ActiveRecord::Migration[5.2]
  def change
    add_index :states, :name
  end
end
