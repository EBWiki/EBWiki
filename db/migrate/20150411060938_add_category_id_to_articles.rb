class AddCategoryIdToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :category_id, :integer
  end
end
