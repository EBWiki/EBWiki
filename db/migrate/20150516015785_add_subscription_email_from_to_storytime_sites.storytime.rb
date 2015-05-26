# This migration comes from storytime (originally 20150224193151)
class AddSubscriptionEmailFromToStorytimeSites < ActiveRecord::Migration
  def change
    add_column :storytime_sites, :subscription_email_from, :string
  end
end
