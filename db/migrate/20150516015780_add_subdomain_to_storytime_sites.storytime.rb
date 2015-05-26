# This migration comes from storytime (originally 20150216211257)
class AddSubdomainToStorytimeSites < ActiveRecord::Migration
  def change
    add_column :storytime_sites, :subdomain, :string
  end
end
