# frozen_string_literal: true

require 'rails_helper'

describe ValueObject do
  subject { ValueObject.new }

  describe '#initialize' do
    it 'should initialize a value object' do
      expect(subject).to be_a(ValueObject)
    end
  end

  describe '#to_s' do
    it 'should return a string' do
      expect { subject.to_s }.to raise_error(NotImplementedError)
    end
  end

  describe '#==' do
    # We mock the to_s method to allow us to test the equality of two value
    before { allow(subject).to receive(:to_s) { 'foo' } }

    it 'should return true if the objects are equal' do
      expect(subject == subject).to be(true)
    end

    it 'should return false if the objects are not equal' do
      expect(subject == 'foo').to be(false)
    end
  end
end
