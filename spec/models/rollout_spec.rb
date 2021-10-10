# frozen_string_literal: true

require 'rails_helper'

describe Rollout do
  subject { described_class.new(path_to_file) }

  let(:path_to_file) { '' }

  it 'has the correct attributes' do
    expect(subject.name).to eq('')
    expect(subject.description).to eq('')
    expect(subject.creator).to eq('')
    expect(subject.date_added).to eq('')
  end

  it 'should return a string representing the date object' do
    expect(subject.to_s).to eq('')
  end

  it 'should mark rollouts with the same dates as equal' do
    second_service = Rollout.new(path_to_file)
    expect(subject == second_service).to be_truthy
  end
end
