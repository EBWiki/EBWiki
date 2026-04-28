# frozen_string_literal: true

class AddTsvToCases < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      ALTER TABLE cases
      ADD COLUMN tsv tsvector
      GENERATED ALWAYS AS (
        to_tsvector('english',
          coalesce(title, '')    || ' ' ||
          coalesce(blurb, '')    || ' ' ||
          coalesce(overview, '') || ' ' ||
          coalesce(city, '')     || ' ' ||
          coalesce(summary, '')
        )
      ) STORED
    SQL

    add_index :cases, :tsv, using: :gin, name: 'index_cases_on_tsv'
  end

  def down
    remove_index :cases, name: 'index_cases_on_tsv'
    remove_column :cases, :tsv
  end
end
