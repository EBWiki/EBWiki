class CreateAgencies < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :name
      t.string :street_address
      t.string :city
      t.integer :state_id
      t.string :zipcode
      t.text :description
      t.string :telephone
      t.string :email
      t.string :website
      t.string :lead_officer

      t.timestamps null: false
    end
  end
end
