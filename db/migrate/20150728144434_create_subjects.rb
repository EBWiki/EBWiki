class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :name
      t.integer :age
      t.integer :gender
      t.integer :ethnicity
      t.boolean :armed
      t.boolean :mentally_ill
      t.boolean :veteran

      t.timestamps null: false
    end
  end
end
