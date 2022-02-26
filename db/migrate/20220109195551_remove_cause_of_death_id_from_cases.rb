class RemoveCauseOfDeathIdFromCases < ActiveRecord::Migration[5.2]
  def change
    remove_column(:cases, :cause_of_death_id, :integer)
  end
end
