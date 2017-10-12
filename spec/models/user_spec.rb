# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is invalid without a name' do
    user = build(:user, name: nil)
    expect(user).to be_invalid
  end
end
