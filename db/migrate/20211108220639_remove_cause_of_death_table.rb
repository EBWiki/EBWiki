class RemoveCauseOfDeathTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :causes_of_death
  end
end
