class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :url
      t.belongs_to :article, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
