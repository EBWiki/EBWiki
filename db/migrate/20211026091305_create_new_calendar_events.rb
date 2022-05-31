class CreateNewCalendarEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :calendar_events do |t|
      t.string :title,       null: false
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :format
      t.text   :description, null: false
      t.jsonb  :schedule,    null: false

      t.belongs_to :owner
    end
  end
end
