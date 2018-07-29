class AddJurisdictionToAgencies < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE jurisdiction AS ENUM ('none', 'local', 'state', 'federal', 'university', 'private');
    SQL

    add_column :agencies, :jurisdiction, :jurisdiction, index: true
  end

  def down
    remove_column :agencies, :jurisdiction

    execute <<-SQL
      DROP TYPE jurisdiction;
    SQL
  end
end
