class AddUserIdtoCalendarEvents < ActiveRecord::Migration
  def change
  	add_column :calendar_events, :user_id, :integer
  end
end
