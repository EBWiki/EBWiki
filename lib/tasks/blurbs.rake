# frozen_string_literal: true

require 'blurb_html_stripper'

namespace :cases do
  desc 'Report or strip HTML tags from legacy case blurbs (dry run unless APPLY=1)'
  task strip_blurb_html: :environment do
    apply = ENV['APPLY'] == '1'
    affected = BlurbHtmlStripper.affected_cases

    puts BlurbHtmlStripper.report(affected)

    if apply
      puts BlurbHtmlStripper.apply!(affected)
    else
      puts 'Dry run only. Set APPLY=1 to write changes.'
    end
  end
end
