# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HarborAddition do
  it 'adds two integers' do
    expect(HarborAddition.add(2, 2)).to eq(4)
  end
end
