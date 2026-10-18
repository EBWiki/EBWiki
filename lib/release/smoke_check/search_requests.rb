# frozen_string_literal: true

module Release
  class SmokeCheck
    # HTTP checks for public pages and search results.
    module SearchRequests
      def verify_home_page
        response = fetch('/')
        assert_ok!(:home_page, response, 'Home page did not return HTTP 200')
      end

      def verify_known_search
        response = fetch(search_path(@search_term))
        assert_ok!(:known_search, response, 'Search with a known term did not return HTTP 200')
        assert_known_search_body(response.body)
      end

      def assert_known_search_body(body)
        assert_includes!(:known_search, body, 'has returned', 'missing results text')
        refute_includes!(:known_search, body, 'has returned 0 results', 'zero results')
      end

      def verify_empty_search
        response = fetch(search_path(JUNK_SEARCH_TERM))
        assert_ok!(:empty_search, response, 'Junk search did not return HTTP 200')
        assert_includes!(
          :empty_search,
          response.body,
          'has returned 0 results',
          'Junk search did not report zero results'
        )
      end

      private

      def search_path(term)
        "/search?query=#{CGI.escape(term)}"
      end
    end
  end
end
