# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bootstrap 3 inventory doc (GKT-909)' do
  it 'documents the spike at the agreed path' do
    path = Rails.root.join('docs/bootstrap/BOOTSTRAP3_INVENTORY.md')
    expect(path).to exist
    contents = path.read
    expect(contents).to include('GKT-909')
    expect(contents).to include('GKT-625')
  end
end
