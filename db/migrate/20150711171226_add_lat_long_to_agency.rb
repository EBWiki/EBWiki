class AddLatLongToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :latitude, :float
    add_column :agencies, :longitude, :float
  end
end
