# frozen_string_literal: true

# Fetches the cases using Redis cache
module MapsHelper
  def fetch_cases
    cases = $redis.get('cases')

    if cases.nil?
      cases = Case.all.to_json
      $redis.set('cases', cases)
      $redis.expire('cases', 2.hour.to_i)
    end
    JSON.load cases
  end
end
