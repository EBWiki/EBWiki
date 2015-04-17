class CreateOfficers < ActiveRecord::Migration
  def change
    create_table :officers do |t|
      t.string :first_name
      t.string :last_name
      t.integer :department_id
      t.string :avatar

      t.timestamps null: false
    end
    
    create_table :articles_officers, id: false do |t|
      t.belongs_to :articles, index: true
      t.belongs_to :officers, index: true
    end
  end
end
