# frozen_string_literal: true

require Rails.root.join('lib/active_storage_cutover/case_avatar_drop_guard')

class RemoveCarrierwaveAvatarColumnsFromCases < ActiveRecord::Migration[8.1]
  def up
    ActiveStorageCutover::CaseAvatarDropGuard.refuse_if_unsafe!
    return if skip_column_drop?

    remove_column :cases, :avatar, :string
    remove_column :cases, :default_avatar_url, :string
    remove_column :cases, :remove_avatar, :boolean
  end

  def down
    add_column :cases, :avatar, :string unless column_exists?(:cases, :avatar)
    add_column :cases, :default_avatar_url, :string unless column_exists?(:cases, :default_avatar_url)
    add_column :cases, :remove_avatar, :boolean unless column_exists?(:cases, :remove_avatar)
  end

  def skip_column_drop?
    if Rails.env.test?
      ENV['EBWIKI_RUN_SLICE_5B_COLUMN_DROP'] != '1'
    else
      ENV['ALLOW_CASE_AVATAR_COLUMN_DROP'] != '1'
    end
  end
end
