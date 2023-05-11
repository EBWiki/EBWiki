class AddDefaultAvatarUrlAsSqlAttribute < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :default_avatar_url, :string
  end
end
