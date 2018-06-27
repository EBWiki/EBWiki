# frozen_string_literal: true

desc 'Count null fields in a column'
task :count_null_fields, %i[model column] => :environment do |task, args|
  abort 'Model or column param missing' if args[:column].blank? || args[:model].blank?
  model = args[:model]
  column = args[:column]
  begin
    count = model.constantize.where("#{column}": nil).count
  rescue StandardError, ActiveRecord::ActiveRecordError => e
    abort "Error: #{e.message}"
  end
  puts "Total NULL values: #{count}"
end
