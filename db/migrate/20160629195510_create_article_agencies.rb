class CreateArticleAgencies < ActiveRecord::Migration
  def change
    drop_table(:article_agencies, if_exists: true)
    create_table :article_agencies do |t|
      t.integer :article_id
      t.integer :agency_id

      t.timestamps null: false
    end
  end
end
