require 'net/http'

url = "https://www.autobus.io/api/snapshots"
params = {
  ENV['AUTOBUS_ACCESS_TOKEN']
}

resp = Net::HTTP.get_response(URI.parse(url, params))

resp_text = resp.body