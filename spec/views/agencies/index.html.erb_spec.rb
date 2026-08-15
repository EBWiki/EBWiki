# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'agencies/index.html.erb', type: :view do
  it 'displays all the agencies' do
    texas = FactoryBot.create(:state_texas)
    houston_pd = FactoryBot.create(:agency, name: 'City of Houston Police Department',
                                            city: 'Houston', state: texas)
    dallas_pd = FactoryBot.create(:agency, name: 'City of Dallas Police Department',
                                           city: 'Dallas', state: texas)
    assign(:agencies, [houston_pd, dallas_pd])
    render

    expect(rendered).to match(/Houston/m)
    expect(rendered).to match(/Dallas/m)
  end
end
