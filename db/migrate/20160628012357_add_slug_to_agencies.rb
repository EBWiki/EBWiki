class AddSlugToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :slug, :string
    add_index :agencies, :slug
  end
end
