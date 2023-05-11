# frozen_string_literal: true

class ValidateNamePresenceOnSubjects < ActiveRecord::Migration[5.2]
  def change
    change_column :subjects, :name, :string, null: false
  end
end
