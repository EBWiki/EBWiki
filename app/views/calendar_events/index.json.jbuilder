json.array!(@calendar_events) do |event|
  json.extract! event, :id, :title, :description
  json.start event.start_time
  json.end event.end_time
  json.url calendar_event_url(event, format: :html)
end