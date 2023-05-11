class AddAnsiCodeIndexToStates < ActiveRecord::Migration[5.2]
  def change
    add_index :states, :ansi_code
  end
end
