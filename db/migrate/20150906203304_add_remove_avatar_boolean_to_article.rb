class AddRemoveAvatarBooleanToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :remove_avatar, :boolean
  end
end
