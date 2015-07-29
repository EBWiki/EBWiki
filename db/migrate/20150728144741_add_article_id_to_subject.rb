class AddArticleIdToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :article_id, :integer
  end
end
