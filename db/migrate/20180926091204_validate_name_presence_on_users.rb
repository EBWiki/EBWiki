# frozen_string_literal: true

class ValidateNamePresenceOnUsers < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :name, :string, null: false
  end
end
