# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'maps/index.html.erb', type: :view do
  it 'displays all the articles' do
    FactoryBot.create(:case, title: 'John Doe')
    FactoryBot.create(
      :case, title: 'Jimmy Doe', state: State.where(ansi_code: 'NY').first
    )
    assign(:cases, Kaminari.paginate_array(
        Case.pluck(:id,
                   :latitude,
                   :longitude,
                   :avatar,
                   :title,
                   :overview)
      ).page(1))
    render

    expect(rendered).to match(/This example displays a movable map initially/m)
  end
end
