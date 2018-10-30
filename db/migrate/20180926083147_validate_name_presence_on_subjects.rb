# frozen_string_literal: true

class ValidateNamePresenceOnSubjects < ActiveRecord::Migration
  def change
    change_column :subjects, :name, :string, null: false
  end
end
