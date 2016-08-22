class CreateArticleDocuments < ActiveRecord::Migration
  def change
    create_table :article_documents do |t|
      t.integer :article_id
      t.integer :document_id

      t.timestamps null: false
    end
  end
end
