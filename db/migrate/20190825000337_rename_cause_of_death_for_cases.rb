class RenameCauseOfDeathForCases < ActiveRecord::Migration[5.0]
  def change
    rename_column :cases, :cause_of_death, :cause_of_death_name
  end
end
