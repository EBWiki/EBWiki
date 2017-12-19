FactoryBot.define do
  factory :visit do
    id 'b3a55b78-182c-459f-aaf0-890d9da33fe6'
    visitor_id '2ba5754c-ae63-4f14-a704-1370842659f2'
    ip '68.173.187.194'
    user_agent 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0'
    referrer ''
    landing_page 'https://blackopswiki.herokuapp.com/'
    browser 'Firefox'
    os 'Ubuntu'
    device_type 'desktop'
    screen_height '1024'
    screen_width '600'
    started_at DateTime.now
  end
end