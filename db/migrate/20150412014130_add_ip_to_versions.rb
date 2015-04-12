class AddIpToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :ip, :string
  end
end
