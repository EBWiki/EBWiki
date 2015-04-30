class AddDataToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :address, :string
    add_column :agencies, :city, :string
    add_column :agencies, :zipcode, :string
    add_column :agencies, :phone, :string
  end
end
