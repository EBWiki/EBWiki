class AddChemicalToCauseOfDeath < ActiveRecord::Migration[5.2][5.0]
  disable_ddl_transaction!

  def change
    execute <<-SQL
      ALTER TYPE cause_of_death ADD VALUE 'chemical_agents_or_weapons';
    SQL
  end
end
