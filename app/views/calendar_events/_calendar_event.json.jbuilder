json.extract! calendar_event, :id, :title, :description, :start_time, :end_time, :latitude, :longitude, :slug, :created_at, :updated_at
json.url calendar_event_url(calendar_event, format: :json)
