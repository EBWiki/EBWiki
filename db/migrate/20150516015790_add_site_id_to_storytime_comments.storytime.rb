# This migration comes from storytime (originally 20150225143826)
class AddSiteIdToStorytimeComments < ActiveRecord::Migration
  def change
    add_column :storytime_comments, :site_id, :integer
    add_index :storytime_comments, :site_id
  end
end
