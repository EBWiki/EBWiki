class AddSlugToGenders < ActiveRecord::Migration[5.2]
  def change
    add_column :genders, :slug, :string
  end
end
