class AddAnsiCodeIndexToStates < ActiveRecord::Migration
  def change
    add_index :states, :ansi_code
  end
end
