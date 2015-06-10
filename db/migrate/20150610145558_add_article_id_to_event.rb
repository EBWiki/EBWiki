class AddArticleIdToEvent < ActiveRecord::Migration
  def change
    add_column :events, :article_id, :integer
  end
end
