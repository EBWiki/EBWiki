# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'cases/history.html.erb', type: :view do
  it 'displays all the articles' do
    this_case = FactoryBot.build(:case, title: 'John Doe')

    assign(:this_case, this_case )
    render

    expect(rendered).to match(/There is no history for this case/m)
  end
end
