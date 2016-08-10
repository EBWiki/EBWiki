desc "Destroy old Autobus backups"
task :autobus_cleanup => :environment do
  p "Autobus Cleanup started!"

  # retrieve autobus backups
  backups = HTTParty.get("https://www.autobus.io/api/snapshots?token=#{ENV['AUTOBUS_ACCESS_TOKEN']}")
  p "Retrieved #{backups.size} backups!"

  # count total memory used by existing snapshots
  total_storage = 0
  backups.each do |snap|
    total_storage += snap["size"]
  end

  # if total memory used is over 99% of capacity, delete the last snapshot
  max_storage = 10000000000
  if total_storage > (max_storage * 99 / 100)
    snap_to_drop_id = backups.last["id"]
    HTTParty.delete("https://www.autobus.io/api/snapshots/#{snap_to_drop_id}?token=#{ENV['AUTOBUS_ACCESS_TOKEN']}")
    p "The oldest snapshot has been deleted!"
  else
    p "We've got plenty of room. No need to destroy anything!"
  end
end