# This migration comes from storytime (originally 20150216225045)
class AddSiteToStorytimeMedia < ActiveRecord::Migration
  def change
    add_column :storytime_media, :site_id, :integer
    add_index :storytime_media, :site_id
  end
end
