class AddColumnsToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :overview, :text
    add_column :articles, :litigation, :text
    add_column :articles, :community_action, :text
  end
end
