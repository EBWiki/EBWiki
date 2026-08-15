# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'maps/index.html.erb', type: :view do
  it 'displays all the articles' do
    FactoryBot.create(:case, title: 'John Doe')
    FactoryBot.create(
      :case, title: 'Jimmy Doe', state: State.where(ansi_code: 'NY').first
    )
    assign(:cases, [[40.7, -74.0], [29.7, -95.3]].flatten.to_json)
    render

    expect(rendered).to match(/Click on the map pins below to learn more/m)
  end
end
