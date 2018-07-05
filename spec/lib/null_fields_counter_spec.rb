# frozen_string_literal: true

require 'rails_helper'

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
  
    it 'should return the correct number of null fields' do
      create_list(:case, 5, :skip_validate, summary: nil)
      expect(NullFieldsCounter.count_null_fields('Case', 'summary')).to include('5')
    end
  end
end
