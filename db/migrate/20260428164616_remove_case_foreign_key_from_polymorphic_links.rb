# frozen_string_literal: true

class RemoveCaseForeignKeyFromPolymorphicLinks < ActiveRecord::Migration[8.1]
  def up
    return unless foreign_key_exists?(:links, :cases, column: :linkable_id)

    remove_foreign_key :links, :cases, column: :linkable_id
  end

  def down
    return if foreign_key_exists?(:links, :cases, column: :linkable_id)

    # Only links pointing at Case rows are FK-safe to re-bind.
    add_foreign_key :links, :cases, column: :linkable_id, validate: false
  end
end
