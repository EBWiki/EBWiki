# frozen_string_literal: true

require "open3"

namespace :db do
  desc "Load the Rails-shaped table subset into the current DATABASE_URL"
  task :load_schema do
    url = ENV.fetch("DATABASE_URL")
    schema = File.expand_path("../../config/db/existing_schema.sql", __dir__)

    stdout, stderr, status = Open3.capture3("psql", url, "-v", "ON_ERROR_STOP=1", "-f", schema)
    abort("Failed to load schema:\n#{stdout}\n#{stderr}") unless status.success?
    puts "Loaded #{schema}"
  end
end
