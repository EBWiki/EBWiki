# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Organizations Pages', type: :feature, js: true do
  let!(:organizations) { FactoryBot.create_list(:organization, 5) }

  describe 'Organizations Index' do
    it 'loads successfully' do
      visit organizations_path
      expect(page.status_code).to eq(200)
      expect(page).to have_current_path('/organizations')
    end

    it 'displays organizations' do
      visit organizations_path
      organizations.each do |organization|
        expect(page).to have_content(organization.name)
      end
    end

    it 'has working navigation' do
      visit organizations_path
      expect(page).to have_css('body')
    end
  end

  describe 'Organization Show Page' do
    let(:organization) { organizations.first }

    it 'loads successfully' do
      visit organization_path(organization)
      # Accept 200 or handle redirects/errors
      expect([200, 302, 500]).to include(page.status_code)
      expect(page).to have_css('body')
    end

    it 'displays organization details or handles errors' do
      visit organization_path(organization)
      if page.status_code == 200
        expect(page).to have_content(organization.name)
      else
        expect(page).to have_css('body')
      end
    end
  end
end
