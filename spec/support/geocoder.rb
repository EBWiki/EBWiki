module Geocoder
  module Lookup
    class Base
      private
      def read_fixture(file)
        # specify the directory where you saved your json file
        File.read(File.join("spec", "fixtures", "geocoder", file)).strip.gsub(/\n\s*/, "")
      end
    end

    class Google < Base
      private
      def fetch_raw_data(query, reverse = false)
        raise TimeoutError if query == "timeout"
        raise SocketError if query == "socket_error"
        file = case query
          when "no results";   :no_results
          when "no locality";  :no_locality
          when "no city data"; :no_city_data
          else                 :madison_square_garden
        end
        # make sure you specify the correct file name here
        read_fixture "google_data.json"
      end
    end
  end
end