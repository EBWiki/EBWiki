class Autobus
  attr_accessor :backups, :url

  #
  def initialize
    @url = ENV["AUTOBUS_SNAPSHOT_URL"] || nil
    @backups = HTTParty.get(url)
  end

  def total_backup_size
    begin
      return nil if @url.blank?
      @backups.map { | backup | backup[:size] || backup['size'] }.compact.sum
    rescue Exception => e
      Rails.logger.error(e)
    end
  end
end