class AddSlugToAgencies < ActiveRecord::Migration
  def change
    unless column_exists? :agencies, :slug
      add_column :agencies, :slug, :string
      add_index :agencies, :slug
    end
  end
end
