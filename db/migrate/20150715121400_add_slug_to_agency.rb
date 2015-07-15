class AddSlugToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :slug, :string
    add_index :agencies, :slug, unique: true
  end
end
