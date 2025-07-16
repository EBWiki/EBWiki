class AddJurisdictionToAgencies < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.connection.execute <<~SQL
      CREATE TYPE jurisdiction AS ENUM ('none', 'local', 'state', 'federal', 'university', 'private');
    SQL
  end
end
