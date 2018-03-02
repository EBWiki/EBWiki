# frozen_string_literal: true

# This library gets backups from the Autobus service as well as returns the
# total backup size from all the Autobus backups. This library is used by the
# Rake task in lib/tasks/autobus_cleanup.rake.
class Autobus
  attr_accessor :backups, :url

  def initialize
    @url = ENV['AUTOBUS_SNAPSHOT_URL'] || nil
    @backups = HTTParty.get(url)
  end

  def total_backup_size
    return nil if @url.blank?
    @backups.map { |backup| backup[:size] || backup['size'] }.compact.sum
  rescue StandardErrorq => e
    Rails.logger.error(e)
  end
end
