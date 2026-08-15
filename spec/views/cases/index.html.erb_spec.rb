# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'cases/index.html.erb', type: :view do
  it 'displays all the cases' do
    case1 = FactoryBot.create(:case, title: 'John Doe')
    case2 = FactoryBot.create(:case, title: 'Jimmy Doe', state: FactoryBot.create(:state_ny))
    FactoryBot.create(:subject, case: case1, name: 'John Doe')
    FactoryBot.create(:subject, case: case2, name: 'Jimmy Doe')
    cases = Case.where(id: [case1.id, case2.id]).includes(:state, :subjects)

    assign(:total_cases, 2)
    assign(:cases, Kaminari.paginate_array(cases.to_a).page(1))
    assign(:recently_updated_cases, Case.sorted_by_update(2))
    assign(:state_objects, SortCollectionOrdinally.call(collection: State.all))
    render

    expect(rendered).to match(/John Doe/m)
    expect(rendered).to match(/Jimmy Doe/m)
  end
end
