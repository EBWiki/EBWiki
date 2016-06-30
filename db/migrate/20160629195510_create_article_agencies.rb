class CreateArticleAgencies < ActiveRecord::Migration
  def change
    unless table_exists?(:article_agencies)
      create_table :article_agencies do |t|
        t.integer :article_id
        t.integer :agency_id

        t.timestamps null: false
      end
    end
  end
end
