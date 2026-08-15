# frozen_string_literal: true

namespace :active_storage do
  desc 'Copy CarrierWave case avatars into Active Storage'
  task migrate_case_avatars: :environment do
    require 'open-uri'

    Case.find_each do |this_case|
      next if this_case.photo.attached?
      next if this_case[:avatar].blank?

      path = Rails.root.join('public', 'uploads', 'case', 'avatar', this_case.id.to_s, this_case[:avatar])
      if File.exist?(path)
        this_case.photo.attach(io: File.open(path), filename: this_case[:avatar])
        puts "Attached local avatar for case #{this_case.id}"
        next
      end

      url = this_case.default_avatar_url.presence
      next if url.blank?

      this_case.photo.attach(io: URI.parse(url).open, filename: File.basename(URI.parse(url).path))
      puts "Attached remote avatar for case #{this_case.id}"
    rescue StandardError => e
      warn "Skipped case #{this_case.id}: #{e.message}"
    end
  end
end
