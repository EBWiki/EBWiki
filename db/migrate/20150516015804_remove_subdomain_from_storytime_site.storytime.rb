# This migration comes from storytime (originally 20150402161427)
class RemoveSubdomainFromStorytimeSite < ActiveRecord::Migration
  def change
    remove_column :storytime_sites, :subdomain, :string
  end
end
