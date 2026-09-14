# frozen_string_literal: true

require "open3"
require "sequel"
require "tmpdir"

namespace :db do
  desc "Load the Rails-shaped table subset into the current DATABASE_URL"
  task :load_schema do
    url = sequel_database_url
    schema = File.expand_path("../../config/db/existing_schema.sql", __dir__)

    if system("which", "psql", out: File::NULL, err: File::NULL)
      stdout, stderr, status = Open3.capture3("psql", url, "-v", "ON_ERROR_STOP=1", "-f", schema)
      abort("Failed to load schema:\n#{stdout}\n#{stderr}") unless status.success?
    else
      db = Sequel.connect(url)
      db.run(File.read(schema))
      db.disconnect
    end

    puts "Loaded #{schema}"
  end

  desc "Load existing_schema.sql only when the cases table is missing"
  task :load_schema_if_needed do
    url = sequel_database_url
    db = Sequel.connect(url)
    present = db.table_exists?(:cases)
    db.disconnect

    if present
      puts "Schema already present"
    else
      Rake::Task["db:load_schema"].invoke
    end
  end

  desc "Restore latest.dump into the current DATABASE_URL (throwaway DB only)"
  task :restore_dump do
    unless ENV["RESTORE_DUMP"] == "1"
      abort "Refusing to restore: set RESTORE_DUMP=1 (throwaway DB only)"
    end

    path = dump_path
    fetch_dump(path) unless dump_ready?(path)
    restore_dump(path)
    Rake::Task["db:adapt_prod_dump"].invoke
    apply_dump_enum
  end

  desc "Rename 2020 dump columns and add cases.tsv if missing"
  task :adapt_prod_dump do
    url = sequel_database_url
    sql = File.expand_path("../../config/db/dump_compat.sql", __dir__)

    if system("which", "psql", out: File::NULL, err: File::NULL)
      stdout, stderr, status = Open3.capture3("psql", url, "-v", "ON_ERROR_STOP=1", "-f", sql)
      abort("Failed to adapt dump schema:\n#{stdout}\n#{stderr}") unless status.success?
    else
      db = Sequel.connect(url)
      db.run(File.read(sql))
      db.disconnect
    end

    puts "Adapted dump schema (#{sql})"
  end
end

HISTORIC_DUMP_COMMIT = "592560514b263c8956d039bdd25c9c8b7fb2a81f"
HISTORIC_DUMP_URL = "https://raw.githubusercontent.com/EBWiki/EBWiki/#{HISTORIC_DUMP_COMMIT}/latest.dump"

def sequel_database_url
  ENV.fetch("DATABASE_URL").sub(/\Apostgresql:/, "postgres:")
end

def dump_path
  ENV.fetch("DUMP_PATH", "/tmp/latest.dump")
end

def dump_ready?(path)
  File.file?(path) && File.size(path) > 1_000_000
end

def fetch_dump(path)
  url = ENV.fetch("DUMP_URL", HISTORIC_DUMP_URL)
  puts "Downloading #{url} -> #{path}"
  stdout, stderr, status = Open3.capture3("curl", "-fsSL", "-o", path, url)
  abort("Failed to download dump:\n#{stdout}\n#{stderr}") unless status.success? && dump_ready?(path)
end

def restore_dump(path)
  url = sequel_database_url
  list_file = File.join(Dir.tmpdir, "ebwiki-dump.list")
  listing, stderr, status = Open3.capture3("pg_restore", "-l", path)
  abort("Failed to list dump:\n#{listing}\n#{stderr}") unless status.success?

  File.write(list_file, listing.lines.reject { |line| line.include?("EXTENSION") }.join)
  stdout, stderr, status = Open3.capture3(
    "pg_restore",
    "--verbose",
    "--clean",
    "--if-exists",
    "--no-acl",
    "--no-owner",
    "-L", list_file,
    "--dbname", url,
    path
  )
  db = Sequel.connect(url)
  cases_present = db.table_exists?(:cases)
  case_count = cases_present ? db[:cases].count : 0
  db.disconnect

  unless cases_present && case_count.positive?
    abort("pg_restore did not load cases:\n#{stdout}\n#{stderr}")
  end

  puts "Restored #{case_count} cases from #{path} (pg_restore exit #{status.exitstatus})"
end

def apply_dump_enum
  url = sequel_database_url
  sql = File.expand_path("../../config/db/dump_enum.sql", __dir__)
  stdout, stderr, status = Open3.capture3("psql", url, "-v", "ON_ERROR_STOP=1", "-f", sql)
  abort("Failed to expand cause_of_death enum:\n#{stdout}\n#{stderr}") unless status.success?
  puts "Expanded cause_of_death enum"
end
