class CreateCalendarEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :calendar_events do |t|
      t.string      :title
      t.datetime    :start_time
      t.datetime    :end_time
      t.text        :description
      t.string      :city
      t.integer     :state_id
    end
  end
end
