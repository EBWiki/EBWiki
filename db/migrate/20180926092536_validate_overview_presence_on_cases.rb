# frozen_string_literal: true

class ValidateOverviewPresenceOnCases < ActiveRecord::Migration[5.2]
  def change
    change_column :cases, :overview, :text, null: false
  end
end
