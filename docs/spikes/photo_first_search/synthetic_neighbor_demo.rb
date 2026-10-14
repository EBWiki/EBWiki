#!/usr/bin/env ruby
# frozen_string_literal: true

# Demonstrates cosine k-NN against pgvector using synthetic 768-dimensional vectors.
# Usage: DATABASE_URL=... ruby docs/spikes/photo_first_search/synthetic_neighbor_demo.rb
# Dry run: DRY_RUN=1 ruby docs/spikes/photo_first_search/synthetic_neighbor_demo.rb

require 'pg'

VECTOR_DIM = 768
TABLE = 'photo_search_spike_embeddings'

def literal_vector(values)
  "[#{values.join(',')}]"
end

# Fixed vectors: b is closest to probe; a and c are farther.
VECTOR_A = Array.new(VECTOR_DIM) { |i| i.even? ? 0.01 : 0.0 }
VECTOR_B = Array.new(VECTOR_DIM) { |i| i.even? ? 0.02 : 0.0 }
VECTOR_C = Array.new(VECTOR_DIM) { |i| i.even? ? 0.0 : 0.01 }
PROBE = VECTOR_B

CREATE_TABLE_SQL = <<~SQL.strip
  CREATE TABLE #{TABLE} (
    case_id bigint PRIMARY KEY,
    embedding vector(#{VECTOR_DIM}) NOT NULL
  )
SQL

KNN_SQL = <<~SQL.strip
  SELECT case_id, (embedding <=> '#{literal_vector(PROBE)}'::vector) AS cosine_distance
  FROM #{TABLE}
  ORDER BY embedding <=> '#{literal_vector(PROBE)}'::vector
  LIMIT 3
SQL

SQL_STEPS = [
  'CREATE EXTENSION IF NOT EXISTS vector',
  "DROP TABLE IF EXISTS #{TABLE}",
  CREATE_TABLE_SQL,
  "INSERT INTO #{TABLE} (case_id, embedding) VALUES (101, '#{literal_vector(VECTOR_A)}'::vector)",
  "INSERT INTO #{TABLE} (case_id, embedding) VALUES (202, '#{literal_vector(VECTOR_B)}'::vector)",
  "INSERT INTO #{TABLE} (case_id, embedding) VALUES (303, '#{literal_vector(VECTOR_C)}'::vector)",
  KNN_SQL,
  "DROP TABLE IF EXISTS #{TABLE}"
].freeze

if ENV['DRY_RUN'] == '1'
  puts '-- DRY RUN: SQL that would execute --'
  SQL_STEPS.each { |sql| puts "#{sql};\n" }
  exit 0
end

database_url = ENV.fetch('DATABASE_URL', nil)
unless database_url
  warn 'Set DATABASE_URL or DRY_RUN=1'
  exit 1
end

conn = PG.connect(database_url)
conn.exec('CREATE EXTENSION IF NOT EXISTS vector')
conn.exec("DROP TABLE IF EXISTS #{TABLE}")
conn.exec(CREATE_TABLE_SQL)

[
  [101, VECTOR_A],
  [202, VECTOR_B],
  [303, VECTOR_C]
].each do |case_id, vec|
  conn.exec_params(
    "INSERT INTO #{TABLE} (case_id, embedding) VALUES ($1, $2::vector)",
    [case_id, literal_vector(vec)]
  )
end

rows = conn.exec(KNN_SQL)

puts 'k-NN results (closest first):'
rows.each { |row| puts "  case_id=#{row['case_id']} distance=#{row['cosine_distance']}" }

conn.exec("DROP TABLE IF EXISTS #{TABLE}")
conn.close

expected = rows.first['case_id']
unless expected == '202'
  warn "Unexpected top match: #{expected} (expected 202)"
  exit 1
end

puts 'Spike OK: nearest neighbor matches case_id 202'
