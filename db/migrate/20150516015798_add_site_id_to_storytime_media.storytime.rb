# This migration comes from storytime (originally 20150302171500)
class AddSiteIdToStorytimeMedia < ActiveRecord::Migration
  def up
    Storytime::Migrators::V1.add_site_id_to_media
  end

  def down
  end
end
