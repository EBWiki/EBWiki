# frozen_string_literal: true

namespace :cases do
  desc 'Report case blurbs that still contain HTML; strip them when APPLY=1'
  task strip_blurb_html: :environment do
    apply = ENV['APPLY'] == '1'
    stripper = ActionController::Base.helpers
    preview_length = 60
    rows_to_change = []

    Case.where.not(blurb: [nil, '']).find_each do |this_case|
      stripped_blurb = stripper.strip_tags(this_case.blurb)
      next if stripped_blurb == this_case.blurb

      rows_to_change << [this_case, stripped_blurb]
    end

    puts "Cases with HTML in blurb: #{rows_to_change.size}"

    rows_to_change.each do |this_case, stripped_blurb|
      before = this_case.blurb.to_s.truncate(preview_length)
      after = stripped_blurb.truncate(preview_length)
      puts "  id=#{this_case.id} slug=#{this_case.slug}"
      puts "    before: #{before}"
      puts "    after:  #{after}"
    end

    if apply
      changed = 0
      rows_to_change.each do |this_case, stripped_blurb|
        # rubocop:disable Rails/SkipsModelValidations -- bulk cleanup; skip slug/geocode/search callbacks
        this_case.update_columns(blurb: stripped_blurb)
        # rubocop:enable Rails/SkipsModelValidations
        changed += 1
      end
      puts "Updated #{changed} case(s)."
    elsif rows_to_change.any?
      puts 'Dry run only (no rows changed). Re-run with APPLY=1 to write.'
    end
  end
end
