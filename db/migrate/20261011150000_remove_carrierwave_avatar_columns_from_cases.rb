# frozen_string_literal: true
# Slice 5b: drop legacy CarrierWave case photo columns at the maintenance window.

require Rails.root.join('lib/active_storage_cutover/case_avatar_drop_guard')

class RemoveCarrierwaveAvatarColumnsFromCases < ActiveRecord::Migration[8.1]
  ALLOW_SWITCH_MESSAGE =
    'RemoveCarrierwaveAvatarColumnsFromCases requires ALLOW_CASE_AVATAR_COLUMN_DROP=1. ' \
    'Do not run this migration during a normal Railway release. ' \
    'Set the variable only during the slice 5b maintenance window after Mark GO ' \
    'and a fresh backup, then run bin/rails db:migrate.'

  def up
    unless allow_column_drop?
      if Rails.env.test?
        say 'Skipping legacy case avatar column drop in test ' \
            '(set EBWIKI_RUN_SLICE_5B_COLUMN_DROP=1 in migration specs to exercise the drop).'
        return
      end

      raise ActiveRecord::MigrationError, ALLOW_SWITCH_MESSAGE
    end

    ActiveStorageCutover::CaseAvatarDropGuard.refuse_if_unsafe!

    remove_column :cases, :avatar, :string
    remove_column :cases, :default_avatar_url, :string
    remove_column :cases, :remove_avatar, :boolean
  end

  def down
    add_column :cases, :avatar, :string unless column_exists?(:cases, :avatar)
    add_column :cases, :default_avatar_url, :string unless column_exists?(:cases, :default_avatar_url)
    add_column :cases, :remove_avatar, :boolean unless column_exists?(:cases, :remove_avatar)
  end

  def allow_column_drop?
    if Rails.env.test?
      ENV['EBWIKI_RUN_SLICE_5B_COLUMN_DROP'] == '1'
    else
      ENV['ALLOW_CASE_AVATAR_COLUMN_DROP'] == '1'
    end
  end
end
