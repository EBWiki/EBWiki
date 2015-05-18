# This migration comes from storytime (originally 20150225164232)
class AddSiteIdToStorytimePermissions < ActiveRecord::Migration
  def change
    add_column :storytime_permissions, :site_id, :integer
    add_index :storytime_permissions, :site_id
  end
end
