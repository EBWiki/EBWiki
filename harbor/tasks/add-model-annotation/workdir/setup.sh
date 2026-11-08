#!/bin/bash
set -euo pipefail

cd /usr/src/ebwiki

export RAILS_ENV=test
export DATABASE_URL=postgres://blackops:ebwiki@postgres:5432/blackops_test
export PGHOST=postgres
export PGUSER=blackops
export PGPASSWORD=ebwiki
export PGDATABASE=blackops_test
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"

/usr/bin/psql --set ON_ERROR_STOP=1 --file db/structure.sql "$DATABASE_URL"

cat > db/migrate/20990101000000_create_harbor_annotation_samples.rb <<'RUBY'
# frozen_string_literal: true

class CreateHarborAnnotationSamples < ActiveRecord::Migration[7.1]
  def change
    create_table :harbor_annotation_samples do |t|
      t.string :label, null: false
      t.timestamps
    end
  end
end
RUBY

cat > app/models/harbor_annotation_sample.rb <<'RUBY'
# frozen_string_literal: true

class HarborAnnotationSample < ApplicationRecord
end
RUBY

bundle exec rails db:migrate
