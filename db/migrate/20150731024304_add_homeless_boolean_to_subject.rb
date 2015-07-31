class AddHomelessBooleanToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :homeless, :boolean
  end
end
