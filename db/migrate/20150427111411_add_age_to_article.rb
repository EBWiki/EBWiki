class AddAgeToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :age, :integer
  end
end
