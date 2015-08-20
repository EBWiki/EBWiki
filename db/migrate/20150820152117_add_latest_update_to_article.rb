class AddLatestUpdateToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :latest_update, :text
  end
end
