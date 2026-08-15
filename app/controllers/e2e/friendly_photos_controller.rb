# frozen_string_literal: true

module E2e
  # Resets Playwright fixtures. The route is only drawn when Wikimedia is stubbed.
  class FriendlyPhotosController < ApplicationController
    skip_forgery_protection

    def reset
      return head :forbidden unless FriendlyPhotos::WikimediaClient.stubbed?

      FriendlyPhotos::E2eSeed.call
      head :ok
    end
  end
end
