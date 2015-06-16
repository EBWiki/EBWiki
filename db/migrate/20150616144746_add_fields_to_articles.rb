class AddFieldsToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :overview, :text
    add_column :articles, :community_action, :text
    add_column :articles, :litigation, :text
  end
end
