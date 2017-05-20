class AddJurisdictionToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :jurisdiction, :string
  end
end
