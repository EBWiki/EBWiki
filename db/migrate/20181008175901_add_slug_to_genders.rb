class AddSlugToGenders < ActiveRecord::Migration
  def change
    add_column :genders, :slug, :string
  end
end
