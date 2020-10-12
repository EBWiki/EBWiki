# frozen_string_literal: true

class ValidateOverviewPresenceOnCases < ActiveRecord::Migration
  def change
    change_column :cases, :overview, :text, null: false
  end
end
