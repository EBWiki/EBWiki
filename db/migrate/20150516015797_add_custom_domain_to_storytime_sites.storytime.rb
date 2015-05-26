# This migration comes from storytime (originally 20150226201739)
class AddCustomDomainToStorytimeSites < ActiveRecord::Migration
  def change
    add_column :storytime_sites, :custom_domain, :string
  end
end
