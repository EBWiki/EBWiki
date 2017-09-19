class AddDefaultAvatarUrlAsSqlAttribute < ActiveRecord::Migration
  def change
    add_column :articles, :default_avatar_url, :string
  end
end
