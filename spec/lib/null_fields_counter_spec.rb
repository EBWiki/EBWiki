# frozen_string_literal: true

require 'rails_helper'
require 'null_fields_counter'


RSpec.describe NullFieldsCounter do
  describe '.count_null_fields' do
    it 'should raise an error when params are missing' do
      expect { NullFieldsCounter.count_null_fields }.to raise_error(ArgumentError)
    end

    it 'should return an error message when the column does not exist' do
      expect(NullFieldsCounter.count_null_fields('Case', 'blah')).to include('Error')
    end

    it 'should return an error message if the model does not exist' do
      expect(NullFieldsCounter.count_null_fields('Blah', 'blah')).to include('Error')
    end
  end
end
