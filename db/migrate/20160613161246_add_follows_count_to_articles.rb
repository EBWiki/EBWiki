class AddFollowsCountToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :follows_count, :integer, :null => false, :default => 0

    Article.reset_column_information
    Article.all.each do |p|
      p.update_attribute :follows_count, p.followers.length
    end
  end

  def self.down
    remove_column :articles, :follows_count
  end
end
