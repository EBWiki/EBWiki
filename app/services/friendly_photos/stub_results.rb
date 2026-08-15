# frozen_string_literal: true

module FriendlyPhotos
  # Deterministic Wikimedia hits for Playwright and other e2e runs.
  class StubResults
    def self.for(_query)
      [
        WikimediaClient::Hit.new(
          source: 'wikimedia_commons',
          title: 'E2E family portrait',
          image_url: 'https://upload.wikimedia.org/wikipedia/commons/a/ab/e2e-portrait.jpg',
          page_url: 'https://commons.wikimedia.org/wiki/File:E2E_family_portrait.jpg',
          license: 'CC BY-SA 4.0',
          author: 'E2E fixture',
          description: 'Family photo portrait'
        ),
        WikimediaClient::Hit.new(
          source: 'wikimedia_commons',
          title: 'E2E booking mugshot',
          image_url: 'https://upload.wikimedia.org/wikipedia/commons/b/bc/e2e-mugshot.jpg',
          page_url: 'https://commons.wikimedia.org/wiki/File:E2E_booking_mugshot.jpg',
          license: 'Public domain',
          author: 'Sheriff',
          description: 'County jail booking photo'
        )
      ]
    end
  end
end
