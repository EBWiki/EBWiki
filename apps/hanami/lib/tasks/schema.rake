# frozen_string_literal: true

require "open3"
require "sequel"

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
end

def sequel_database_url
  ENV.fetch("DATABASE_URL").sub(/\Apostgresql:/, "postgres:")
end
