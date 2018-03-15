# frozen_string_literal: true

AUTOBUS_SNAPSHOT_URL = 'https://www.autobus.io/api/snapshots'
AUTOBUS_SNAPSHOT_QUERY = '?token='
desc 'Destroy old Autobus backups'
task autobus_cleanup: :environment do
  p 'Autobus Cleanup started!'

  # retrieve autobus backups
  backups = HTTParty.get("#{AUTOBUS_SNAPSHOT_URL}#{ENV['AUTOBUS_ACCESS_TOKEN']}")
  p "Retrieved #{backups.size} backups!"

  # count total memory used by existing snapshots
  total_storage = Autobus.new.total_backup_size

  # if total memory used is over 99% of capacity, delete the last snapshot
  max_storage = 10_000_000_000 # 10gb limit on current plan
  while total_storage > (max_storage * 99 / 100)
    memory_2_b_freed = backups.last['size']

    snap_to_drop_id = backups.last['id']
    backups.delete_if { |h| h['id'] == snap_to_drop_id }
    HTTParty.delete("https://www.autobus.io/api/snapshots/#{snap_to_drop_id}" \
      "?token=#{ENV['AUTOBUS_ACCESS_TOKEN']}")
    p 'The oldest snapshot has been deleted!'
    total_storage -= memory_2_b_freed
  end
  p "We've got plenty of room now. No need to destroy anything!"
end
