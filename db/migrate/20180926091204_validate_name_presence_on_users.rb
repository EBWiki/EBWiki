# frozen_string_literal: true

class ValidateNamePresenceOnUsers < ActiveRecord::Migration
  def change
    change_column :users, :name, :string, null: false
  end
end
