class AddSlugGenders < ActiveRecord::Migration
  def change
    add_column :genders, :slug, :string
    add_index :genders, :slug, unique: true
  end
end
