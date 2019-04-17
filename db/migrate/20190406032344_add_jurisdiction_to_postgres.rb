class AddJurisdictionToPostgres < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE jurisdiction AS ENUM ('unknown', 'local', 'state', 'federal', 'university', 'commercial')
    SQL

    add_column :agencies, :jurisdiction, :jurisdiction, index: true, default: 'unknown'
  end

  def down
    remove_column :agencies, :jurisdiction

    execute <<-SQL
      DROP TYPE jurisdiction;
    SQL
  end
end
