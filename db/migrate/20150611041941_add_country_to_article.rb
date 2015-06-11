class AddCountryToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :country, :string
  end
end
