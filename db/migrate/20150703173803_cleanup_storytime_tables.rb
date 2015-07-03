class CleanupStorytimeTables < ActiveRecord::Migration
  def change
  	drop_table :storytime_actions if ActiveRecord::Base.connection.table_exists? :storytime_actions
		drop_table :storytime_autosaves if ActiveRecord::Base.connection.table_exists? :storytime_autosaves
		drop_table :storytime_media if ActiveRecord::Base.connection.table_exists? :storytime_media
		drop_table :storytime_memberships	if ActiveRecord::Base.connection.table_exists? :storytime_memberships
		drop_table :storytime_permissions if ActiveRecord::Base.connection.table_exists? :storytime_permissions
		drop_table :storytime_posts	if ActiveRecord::Base.connection.table_exists? :storytime_posts
		drop_table :storytime_roles if ActiveRecord::Base.connection.table_exists? :storytime_roles
		drop_table :storytime_sites	if ActiveRecord::Base.connection.table_exists? :storytime_sites
		drop_table :storytime_snippets if ActiveRecord::Base.connection.table_exists? :storytime_snippets
		drop_table :storytime_subscriptions if ActiveRecord::Base.connection.table_exists? :storytime_subscriptions
		drop_table :storytime_taggings if ActiveRecord::Base.connection.table_exists? :storytime_taggings
		drop_table :storytime_tags if ActiveRecord::Base.connection.table_exists? :storytime_tags
		drop_table :storytime_versions if ActiveRecord::Base.connection.table_exists? :storytime_versions
  end
end