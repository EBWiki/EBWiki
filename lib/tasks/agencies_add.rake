# frozen_string_literal: true

desc 'Create Agencies from csv'
task agencies_add: :environment do
  p 'Task started!'
  filepath = File.dirname __FILE__
  file_name = '/agencies.csv'

  CSV.foreach(filepath + file_name, headers: true) do |agency|
    agency_hash = agency.to_hash
    agency = Agency.new(
      name: agency_hash['Agency'],
      # phone: agency_hash["Phone"],
      # address: agency_hash["Address"],
      # city: agency_hash["City"],
      state_id: agency_hash['State_id'],
      # zipcode: agency_hash["Zip"],
    )
    agency.save
    p 'Created!'
  end
  p 'Done!'
end
