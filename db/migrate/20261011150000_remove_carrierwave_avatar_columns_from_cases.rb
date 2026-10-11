# frozen_string_literal: true

require Rails.root.join('lib/active_storage_cutover/case_avatar_drop_guard')

class RemoveCarrierwaveAvatarColumnsFromCases < ActiveRecord::Migration[8.1]
  def up
    ActiveStorageCutover::CaseAvatarDropGuard.refuse_if_unsafe!

    remove_column :cases, :avatar, :string
    remove_column :cases, :default_avatar_url, :string
    remove_column :cases, :remove_avatar, :boolean
  end

  def down
    add_column :cases, :avatar, :string
    add_column :cases, :default_avatar_url, :string
    add_column :cases, :remove_avatar, :boolean
  end
end
