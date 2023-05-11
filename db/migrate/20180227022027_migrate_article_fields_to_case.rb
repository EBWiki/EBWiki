class MigrateArticleFieldsToCase < ActiveRecord::Migration[5.2]
  def change
    rename_table :articles, :cases
    rename_table :article_agencies, :case_agencies
    rename_table :article_officers, :case_officers
    rename_column :subjects, :article_id, :case_id
    rename_column :case_agencies, :article_id, :case_id
    rename_column :case_officers, :article_id, :case_id
    rename_column :links, :article_id, :case_id
    if index_exists?(:links, :index_links_on_article_id)
      remove_index :links, :article_id
      add_index :links, ["case_id"], name: "index_links_on_case_id", using: :btree
    end
  end
end
