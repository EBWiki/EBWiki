class AddDetailsToStates < ActiveRecord::Migration
  def change
    add_column :states, :ansi_code, :string
  end
end
