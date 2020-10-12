# frozen_string_literal: true

namespace :cases do
  desc 'Add blurb to cases'
  task add_blurb: :environment do
    cases = Case.all
    puts "Going to update #{cases.count} cases"

    # rubocop:disable Layout/LineLength
    ActiveRecord::Base.transaction do
      cases.each do |this_case|
        this_case.update_attribute :blurb, "#{this_case.title}, on #{this_case.date} in #{this_case.city}, #{this_case.state.name}"
        print '.'
      end
    end
    # rubocop:enable Layout/LineLength
  end

  desc 'Convert cause of death to enum'
  task convert_cause_of_death: :environment do
    causes_of_death = CauseOfDeath.where.not(name: 'Unknown').pluck(:id, :name).to_h
    lookup = causes_of_death.map { |k, v| [k, v.downcase.parameterize(separator: '_').to_sym] }.to_h

    lookup.each do |k, v|
      Case.where(cause_of_death_id: k).in_batches do |group|
        group.update_all(cause_of_death_name: v)
      end
    end
  end
end
