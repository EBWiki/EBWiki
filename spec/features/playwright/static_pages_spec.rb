# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Static Pages', type: :feature, js: true do
  describe 'About page' do
    it 'loads successfully' do
      visit '/about'
      expect(page.status_code).to eq(200)
      expect(page).to have_current_path('/about')
    end

    it 'displays content' do
      visit '/about'
      expect(page).to have_css('body')
    end
  end

  describe 'Guidelines page' do
    it 'loads successfully' do
      visit '/guidelines'
      expect(page.status_code).to eq(200)
      expect(page).to have_current_path('/guidelines')
    end

    it 'displays content' do
      visit '/guidelines'
      expect(page).to have_css('body')
    end
  end

  describe 'Instructions page' do
    it 'loads successfully' do
      visit '/instructions'
      expect(page.status_code).to eq(200)
      expect(page).to have_current_path('/instructions')
    end

    it 'displays content' do
      visit '/instructions'
      expect(page).to have_css('body')
    end
  end

  describe 'Get Involved page' do
    it 'loads successfully' do
      visit '/get-involved'
      expect(page.status_code).to eq(200)
      expect(page).to have_current_path('/get-involved')
    end

    it 'displays content' do
      visit '/get-involved'
      expect(page).to have_css('body')
    end
  end

  describe 'How to Help page' do
    it 'loads successfully' do
      visit '/how-to-help'
      expect(page.status_code).to eq(200)
      expect(page).to have_current_path('/how-to-help')
    end

    it 'displays content' do
      visit '/how-to-help'
      expect(page).to have_css('body')
    end
  end
end
