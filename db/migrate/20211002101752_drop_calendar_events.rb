class DropCalendarEvents < ActiveRecord::Migration[5.2]
  def change
    drop_table :calendar_events
  end
end
