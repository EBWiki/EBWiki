# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subject, type: :model do
  it 'is invalid without a name' do
    subject = build(:subject, name: nil)
    expect(subject).to be_invalid
  end
end
