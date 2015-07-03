class CleanupStorytimeTables < ActiveRecord::Migration
  def change
  	drop_table :storytime_actions
		drop_table :storytime_autosaves
		drop_table :storytime_media
		drop_table :storytime_memberships		
		drop_table :storytime_permissions
		drop_table :storytime_posts		
		drop_table :storytime_roles
		drop_table :storytime_sites		
		drop_table :storytime_snippets
		drop_table :storytime_subscriptions		
		drop_table :storytime_taggings
		drop_table :storytime_tags		
		drop_table :storytime_versions
  end
end