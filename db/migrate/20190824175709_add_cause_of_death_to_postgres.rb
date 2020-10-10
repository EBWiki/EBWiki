class AddCauseOfDeathToPostgres < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE TYPE cause_of_death AS ENUM ('choking', 'shooting', 'beating', 'taser', 'vehicular', 'medical neglect', 'response to medical emergency', 'suicide')
    SQL

    add_column :cases, :cause_of_death, :cause_of_death, index: true
  end

  def down
    remove_column :cases, :cause_of_death

    execute <<-SQL
      DROP TYPE cause_of_death;
    SQL
  end
end
