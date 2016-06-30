class CreateAgencies < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :name
      t.integer :state_id
      t.string :state

      t.timestamps null: false
    end
  end
end
