class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.text :description
      t.string :website
      t.string :telephone
      t.string :avatar

      t.timestamps null: false
    end
  end
end
