# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Globe case points', type: :system do
  before do
    create(:case, title: 'Globe Visible Case', city: 'Albany')
  end

  it 'renders case entities after loading the globe' do
    visit globe_maps_path

    expect(page).to have_css('#globe-viewport[data-case-count]', wait: 20)
    expect(page.find('#globe-viewport')['data-case-count'].to_i).to be >= 1

    entity_count = page.evaluate_script('window.__ebwikiGlobeEntityCount')
    expect(entity_count).to be >= 1
    expect(page.evaluate_script('window.__ebwikiGlobeReady')).to be true
  end
end
