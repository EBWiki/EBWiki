# This migration comes from storytime (originally 20150302192525)
class TransferPostsToBlogs < ActiveRecord::Migration
  def up
    Storytime::Migrators::V1.transfer_posts_to_blogs
  end

  def down
  end
end
