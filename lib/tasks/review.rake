# frozen_string_literal: true

module ReviewMapSeed
  STATES = [
    { ansi_code: 'CA', iso: 'US-CA', name: 'California' },
    { ansi_code: 'GA', iso: 'US-GA', name: 'Georgia' },
    { ansi_code: 'KY', iso: 'US-KY', name: 'Kentucky' },
    { ansi_code: 'LA', iso: 'US-LA', name: 'Louisiana' },
    { ansi_code: 'MD', iso: 'US-MD', name: 'Maryland' },
    { ansi_code: 'MN', iso: 'US-MN', name: 'Minnesota' },
    { ansi_code: 'MO', iso: 'US-MO', name: 'Missouri' },
    { ansi_code: 'NY', iso: 'US-NY', name: 'New York' },
    { ansi_code: 'OH', iso: 'US-OH', name: 'Ohio' },
    { ansi_code: 'SC', iso: 'US-SC', name: 'South Carolina' },
    { ansi_code: 'TX', iso: 'US-TX', name: 'Texas' }
  ].freeze

  CASES = [
    { title: 'Walter Scott', city: 'North Charleston', state: 'SC',
      lat: 32.8546, lng: -79.9748, date: Date.new(2015, 4, 4) },
    { title: 'Eric Garner', city: 'Staten Island', state: 'NY',
      lat: 40.6362, lng: -74.0762, date: Date.new(2014, 7, 17) },
    { title: 'Michael Brown', city: 'Ferguson', state: 'MO',
      lat: 38.7442, lng: -90.3054, date: Date.new(2014, 8, 9) },
    { title: 'Tamir Rice', city: 'Cleveland', state: 'OH',
      lat: 41.4528, lng: -81.5801, date: Date.new(2014, 11, 22) },
    { title: 'Freddie Gray', city: 'Baltimore', state: 'MD',
      lat: 39.3046, lng: -76.6413, date: Date.new(2015, 4, 12) },
    { title: 'Philando Castile', city: 'Falcon Heights', state: 'MN',
      lat: 44.9916, lng: -93.1666, date: Date.new(2016, 7, 6) },
    { title: 'Alton Sterling', city: 'Baton Rouge', state: 'LA',
      lat: 30.4515, lng: -91.1871, date: Date.new(2016, 7, 5) },
    { title: 'Breonna Taylor', city: 'Louisville', state: 'KY',
      lat: 38.2527, lng: -85.7585, date: Date.new(2020, 3, 13) },
    { title: 'George Floyd', city: 'Minneapolis', state: 'MN',
      lat: 44.9344, lng: -93.2478, date: Date.new(2020, 5, 25) },
    { title: 'Botham Jean', city: 'Dallas', state: 'TX',
      lat: 32.7767, lng: -96.7970, date: Date.new(2018, 9, 6) },
    { title: 'Atatiana Jefferson', city: 'Fort Worth', state: 'TX',
      lat: 32.7555, lng: -97.3308, date: Date.new(2019, 10, 12) },
    { title: 'Stephon Clark', city: 'Sacramento', state: 'CA',
      lat: 38.5816, lng: -121.4944, date: Date.new(2018, 3, 18) },
    { title: 'Oscar Grant', city: 'Oakland', state: 'CA',
      lat: 37.8044, lng: -122.2712, date: Date.new(2009, 1, 1) },
    { title: 'Sandra Bland', city: 'Prairie View', state: 'TX',
      lat: 30.0930, lng: -96.0002, date: Date.new(2015, 7, 13) },
    { title: 'Ahmaud Arbery', city: 'Satilla Shores', state: 'GA',
      lat: 31.1499, lng: -81.4915, date: Date.new(2020, 2, 23) }
  ].freeze

  module_function

  def run
    Case.skip_callback(:save, :before, :geocode)
    ensure_states
    ensure_cases
    Rails.cache.delete('case_map_locations_v2')
    puts "Seeded #{Case.with_location.count} geocoded cases"
  end

  def ensure_states
    STATES.each do |attrs|
      State.find_or_create_by!(ansi_code: attrs[:ansi_code]) do |state|
        state.assign_attributes(attrs)
      end
    end
  end

  def ensure_cases
    CASES.each { |attrs| upsert_case(attrs) }
  end

  def upsert_case(attrs)
    state = State.find_by!(ansi_code: attrs[:state])
    this_case = Case.find_or_initialize_by(title: attrs[:title])
    this_case.assign_attributes(case_attributes(attrs, state))
    this_case.save!
  end

  def case_attributes(attrs, state)
    {
      city: attrs[:city],
      state: state,
      date: attrs[:date],
      latitude: attrs[:lat],
      longitude: attrs[:lng],
      overview: "Documented case of #{attrs[:title]} in #{attrs[:city]}.",
      summary: 'Seeded for the Railway map preview.',
      blurb: "#{attrs[:title]} was killed in #{attrs[:city]}, #{state.name}."
    }
  end
end

namespace :review do
  desc 'Seed a handful of geocoded cases so the Railway map preview has pins'
  task seed_map_cases: :environment do
    ReviewMapSeed.run
  end
end
