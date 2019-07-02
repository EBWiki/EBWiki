# frozen_string_literal: true

FactoryBot.define do
  factory :visit, class: 'Ahoy::Visit' do |f|
    f.sequence (:id) { SecureRandom.uuid }
    f.visitor_id { SecureRandom.uuid }
    f.ip { Faker::Internet.ip_v4_address }
    f.user_agent { Faker::Internet.user_agent(:firefox) }
    f.referrer { '' }
    f.landing_page { 'https://blackopswiki.herokuapp.com/' }
    f.browser { 'Firefox' }
    f.os { 'Ubuntu' }
    f.device_type { 'desktop' }
    f.screen_height { '1024' }
    f.screen_width { '600' }
    f.started_at { Time.current }
  end
end
