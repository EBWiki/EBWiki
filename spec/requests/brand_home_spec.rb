# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Branded home page', type: :request do
  describe 'GET /' do
    before { get '/' }

    it 'returns 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders header and footer wordmark markup' do
      expect(response.body).to include('ebwiki-site-header')
      expect(response.body).to include('ebwiki-wordmark-link')
      expect(response.body).to include('ebwiki-wordmark')
      expect(response.body).to include('ebwiki-footer-wordmark')
      expect(response.body).to include('aria-label="EBWiki"')
    end

    it 'links stylesheets with relative asset paths when no asset host is configured' do
      expect(Rails.application.config.action_controller.asset_host).to be_blank

      hrefs = response.body.scan(/<link[^>]*rel="stylesheet"[^>]*href="([^"]+)"/i)
      hrefs += response.body.scan(/<link[^>]*href="([^"]+)"[^>]*rel="stylesheet"/i)
      expect(hrefs.flatten).not_to be_empty
      expect(hrefs.flatten).to all(match(%r{\A/assets/}))
      expect(hrefs.flatten).not_to(be_any { |href| href.match?(%r{\Ahttps?://}) })
    end
  end
end
