# frozen_string_literal: true

require 'null_fields_counter'

desc 'Count null fields in a column'
# rubocop:disable Lint/UnusedBlockArgument
task :count_null_fields, %i[model column] => :environment do |task, args|
  # rubocop:enable Lint/UnusedBlockArgument
  abort 'Model or column param missing' if args[:column].blank? || args[:model].blank?
  puts NullFieldsCounter.count_null_fields(args[:model], args[:column])
end
