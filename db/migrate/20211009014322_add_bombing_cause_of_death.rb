# frozen_string_literal: true

class AddBombingCauseOfDeath < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    execute <<-SQL
      ALTER TYPE cause_of_death ADD VALUE 'bombing';
    SQL
  end
end
