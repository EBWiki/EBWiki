# frozen_string_literal: true

namespace :active_storage do
  desc 'Copy leftover CarrierWave case files into Active Storage'
  task migrate_case_avatars: :environment do
    Case.find_each do |this_case|
      next if this_case.photo.attached?

      dir = Rails.public_path.join('uploads', 'case', 'avatar', this_case.id.to_s)
      next unless Dir.exist?(dir)

      file = Dir.children(dir).map { |name| dir.join(name) }.find { |path| File.file?(path) }
      next unless file

      this_case.photo.attach(io: File.open(file), filename: File.basename(file))
      puts "Attached local avatar for case #{this_case.id}"
    rescue StandardError => e
      warn "Skipped case #{this_case.id}: #{e.message}"
    end
  end
end
