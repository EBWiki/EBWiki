# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Link, type: :model do
  it { should validate_presence_of(:url) }

  it 'requires a linkable record' do
    link = build(:link, linkable: nil)

    expect(link).not_to be_valid
    expect(link.errors[:linkable]).to include('must exist')
  end
end
