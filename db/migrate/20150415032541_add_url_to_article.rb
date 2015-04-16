class AddUrlToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :video_url, :string
  end
end
