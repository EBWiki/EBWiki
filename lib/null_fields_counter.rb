# frozen_string_literal: true

# This module counts the number of null fields in a given column
# Parameters: Model, column
module NullFieldsCounter
  def self.count_null_fields(model, column)
    begin
      count = model.constantize.where("#{column}": nil).size
    rescue StandardError, ActiveRecord::ActiveRecordError => e
      return "Error: #{e.message}"
    end
    "Total NULL values: #{count}"
  end
end
