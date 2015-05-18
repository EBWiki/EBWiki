# This migration comes from storytime (originally 20150220184902)
class AddBlogIdToPosts < ActiveRecord::Migration
  def change
    add_column :storytime_posts, :blog_id, :integer
    add_index :storytime_posts, :blog_id
  end
end
