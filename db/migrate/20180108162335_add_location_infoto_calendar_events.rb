class AddLocationInfotoCalendarEvents < ActiveRecord::Migration
  def change
  	add_column :calendar_events, :address, :string
  	add_column :calendar_events, :city, :string
  	add_column :calendar_events, :state_id, :integer
  	add_column :calendar_events, :zipcode, :string
  end
end
