# frozen_string_literal: true

require 'rails_helper'

class CounterClass
  include NullFieldsCounter
end

RSpec.describe NullFieldsCounter do
  let(:dc) { DummyClass.new }
  describe '.count_null_fields' do
    it 'should raise an error when params are missing' do
      expect { DummyClass.count_null_fields }.to raise_error(ArgumentError)
    end

    it 'should return an error message when the column does not exist' do
      expect(DummyClass.count_null_fields('Case', 'blah')).to include('Error')
    end

    it 'should return an error message if the model does not exist' do
      expect(DummyClass.count_null_fields('Blah', 'blah')).to include('Error')
    end
  end
end
