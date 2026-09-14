# frozen_string_literal: true

require "rake"

RSpec.describe "db dump restore tasks", :db do
  def db
    Hanami.app["db.rom"].gateways[:default].connection
  end

  def invoke(task_name)
    Rake::Task[task_name].reenable
    Rake::Task[task_name].invoke
  end

  before(:all) do
    Rake.application.rake_require("tasks/schema", [Hanami.app.root.join("lib").to_s])
    Rake::Task.define_task(:environment)
  end

  it "refuses to restore without RESTORE_DUMP=1" do
    previous = ENV.delete("RESTORE_DUMP")
    expect { invoke("db:restore_dump") }.to raise_error(SystemExit, /RESTORE_DUMP=1/)
  ensure
    ENV["RESTORE_DUMP"] = previous if previous
  end

  it "renames cause_of_death_name and adds tsv" do
    db.run("ALTER TABLE cases DROP COLUMN IF EXISTS tsv")
    db.run("ALTER TABLE cases RENAME COLUMN cause_of_death TO cause_of_death_name")
    db.run(File.read(Hanami.app.root.join("config/db/dump_compat.sql")))

    columns = db[:cases].columns
    expect(columns).to include(:cause_of_death)
    expect(columns).not_to include(:cause_of_death_name)
    expect(columns).to include(:tsv)
  end
end
