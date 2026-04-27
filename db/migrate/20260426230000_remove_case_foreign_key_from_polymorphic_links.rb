# frozen_string_literal: true

class RemoveCaseForeignKeyFromPolymorphicLinks < ActiveRecord::Migration[8.1]
  def change
    return unless foreign_key_exists?(:links, :cases, column: :linkable_id)

    remove_foreign_key :links, column: :linkable_id
  end
end
