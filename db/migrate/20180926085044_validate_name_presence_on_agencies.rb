# frozen_string_literal: true

class ValidateNamePresenceOnAgencies < ActiveRecord::Migration[5.2]
  def change
    change_column :agencies, :name, :string, null: false
  end
end
