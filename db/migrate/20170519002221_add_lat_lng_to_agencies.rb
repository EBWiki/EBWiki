class AddLatLngToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :longitude, :float
    add_column :agencies, :latitude, :float
  end
end
