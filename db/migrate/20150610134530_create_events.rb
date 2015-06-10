class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :date
      t.text :description
      t.string :media_url
      t.string :media_credit

      t.timestamps null: false
    end
  end
end
