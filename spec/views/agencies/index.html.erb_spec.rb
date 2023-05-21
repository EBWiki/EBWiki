# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'agencies/index.html.erb', type: :view do
  xit 'displays all the agencies' do
    houston_pd = FactoryBot.build(:agency, name: 'City of Houston Police Department', city: 'Houston', state: State.find_by_name("Texas"))
    beaumont_pd = FactoryBot.build(:agency,  name: 'City of Beaumont Police Department', city: 'Beaumont', state: State.find_by_name("Texas"))
    assign(:cases, Kaminari.paginate_array([houston_pd, beaumont_pd]).page(1))

    assign(:agencies, SortCollectionOrdinally.call(collection: Agency.all))
    render

    expect(rendered).to match(/Houston/m)
    expect(rendered).to match(/Beaumont/m)
  end
end
