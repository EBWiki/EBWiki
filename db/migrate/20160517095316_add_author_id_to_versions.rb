class AddAuthorIdToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :author_id, :integer
  end
end
