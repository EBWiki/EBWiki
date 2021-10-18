# frozen_string_literal: true

require 'rails_helper'

describe Rollout do
  subject { described_class.new(pathname: pathname) }

  let(:pathname) { 'spec/fixtures/rollout.yml' }
  let(:name) { 'Peter' }

  it 'has the correct attributes' do
    expect(subject.name).to eq(name)
    expect(subject.description).to eq('This is a description')
    expect(subject.creator).to eq('Parker')
    expect(subject.date_added).to eq('10/10/10')
  end

  it 'should return a string representing the rollout object' do
    expect(subject.to_s).to eq(name)
  end

  it 'should mark rollouts with the same name as equal' do
    second_service = Rollout.new(pathname: pathname)
    expect(subject == second_service).to be_truthy
  end
end
