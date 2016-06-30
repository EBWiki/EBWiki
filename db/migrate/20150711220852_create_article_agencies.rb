class CreateArticleAgencies < ActiveRecord::Migration
  def change
    create_table :article_agencies do |t|
      t.integer :article_id
      t.integer :agency_id

      t.timestamps null: false
    end
  end
end
