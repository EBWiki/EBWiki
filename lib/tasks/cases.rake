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
end
