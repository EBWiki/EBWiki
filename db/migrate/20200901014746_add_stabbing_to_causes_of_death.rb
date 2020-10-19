# frozen_string_literal: true

class AddStabbingToCausesOfDeath < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!
  def change
    execute <<-SQL
      ALTER TYPE cause_of_death ADD VALUE 'stabbing';
    SQL
  end
end
