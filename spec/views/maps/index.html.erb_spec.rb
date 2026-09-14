# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'maps/index.html.erb', type: :view do
  it 'displays the case map and pin instructions' do
    assign(:cases, [
             {
               lat: 42.6525793,
               lng: -73.7562317,
               title: 'John Doe',
               slug: 'john-doe',
               city: 'Albany',
               url: '/cases/john-doe'
             }
           ])

    render

    expect(rendered).to match(/Click on the map pins below to learn more/m)
    expect(rendered).to include('id="map-container"')
    expect(rendered).to include('John Doe')
    expect(rendered).to include('Showing 1 documented case')
  end
end
