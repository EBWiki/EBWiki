class RenameCauseOfDeathNameColumn < ActiveRecord::Migration[5.2][5.2]
  def change
    rename_column(:cases, :cause_of_death_name, :cause_of_death)
  end
end
