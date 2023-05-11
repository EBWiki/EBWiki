class MigrateCategoryFieldsToCauseOfDeath < ActiveRecord::Migration[5.2]
  def change
    rename_table :categories, :causes_of_death
    rename_column :cases, :category_id, :cause_of_death_id
  end
end
