class CreateCalendarEvents < ActiveRecord::Migration
  drop_table :calendar_events if (table_exists? :calendar_events)
  def change
    create_table :calendar_events do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.float :latitude
      t.float :longitude
      t.string :slug

      t.timestamps null: false
    end
  end
end
