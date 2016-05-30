class AddSummaryToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :summary, :text, :limit => 140
  end
end
