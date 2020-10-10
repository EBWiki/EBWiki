class RemoveJurisdictionFromAgencies < ActiveRecord::Migration
  def up
    remove_column :agencies, :jurisdiction

    ActiveRecord::Base.connection.execute <<-SQL
      DROP TYPE jurisdiction;
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE TYPE jurisdiction as ENUM ('none', 'local', 'state', 'federal', 'university', 'private');
    SQL

    add_column :agencies, :jurisdiction, :jurisdiction, index: true
  end
end
