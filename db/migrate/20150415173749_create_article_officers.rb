class CreateArticleOfficers < ActiveRecord::Migration
  def change
    create_table :article_officers do |t|
      t.integer :article_id
      t.integer :officer_id

      t.timestamps null: false
    end
  end
end
