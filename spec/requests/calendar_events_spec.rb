require 'rails_helper'

RSpec.describe "CalendarEvents", type: :request do
  describe "GET /calendar_events" do
    it "works! (now write some real specs)" do
      get calendar_events_path
      expect(response).to have_http_status(200)
    end
  end
end
