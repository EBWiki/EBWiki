# frozen_string_literal: true

addresses = {
  'New York City NY' => {
    'latitude' => 40.7573862,
    'longitude' => -73.9881256,
    'address' => '230 West 43rd St.',
    'city' => 'New York City',
    'state' => 'New York',
    'state_code' => 'NY',
    'country' => 'United States',
    'country_code' => 'US'
  }, '230 West 43rd St. New York City NY 10036' => {
    'latitude' => 40.7573862,
    'longitude' => -73.9881256,
    'address' => '230 West 43rd St., New York City, NY 10036',
    'city' => 'New York City',
    'state' => 'New York',
    'state_code' => 'NY',
    'country' => 'United States',
    'country_code' => 'US'
  },
  [40.75747130000001, -73.9877319] => {
    'latitude' => 40.75747130000001,
    'longitude' => -73.9877319,
    'address' => '229 West 43rd St., New York City, NY 10036',
    'city' => 'New York City',
    'state' => 'New York',
    'state_code' => 'NY',
    'country' => 'United States',
    'country_code' => 'US'
  },
  '1867 Irving Road Worthington OH 43085' => {
    'latitude' => 40.09846115112305,
    'longitude' => -83.01747131347656,
    'address' => 'Worthington, OH',
    'city' => 'Worthington',
    'state' => 'Ohio',
    'state_code' => 'OH',
    'country' => 'United States',
    'country_code' => 'US'
  },
  'Albany NY' => {
    'latitude' => 42.6525793,
    'longitude' => -73.7562317,
    'address' => 'Albany, NY',
    'city' => 'Albany',
    'state' => 'New York',
    'state_code' => 'NY',
    'country' => 'United States',
    'country_code' => 'US'
  },
  'NY' => {
    'latitude' => 42.6525793,
    'longitude' => -73.7562317,
    'address' => 'Albany, NY',
    'city' => 'Albany',
    'state' => 'New York',
    'state_code' => 'NY',
    'country' => 'United States',
    'country_code' => 'US'
  },
  'Buffalo NY' => {
    'latitude' => 42.6525793,
    'longitude' => -73.7562317,
    'address' => 'Albany, NY',
    'city' => 'Albany',
    'state' => 'New York',
    'state_code' => 'NY',
    'country' => 'United States',
    'country_code' => 'US'
  }

}

Geocoder.configure(lookup: :test)
addresses.each { |lookup, results| Geocoder::Lookup::Test.add_stub(lookup, [results]) }
