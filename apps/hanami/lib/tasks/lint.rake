# frozen_string_literal: true

require "tmpdir"

DAWN_KB_VERSION = "v20240116"
DAWN_KB_URL = "https://github.com/thesp0nge/dawnscanner_knowledge_base/releases/download/#{DAWN_KB_VERSION}/kb.tar.gz"

desc "Run Standard Ruby, the preferred style for this app"
task :lint do
  sh "bundle exec standardrb"
end

namespace :security do
  desc "Download the Dawnscanner knowledge base if missing"
  task :dawn_kb do
    kb_yaml = File.join(Dir.home, "dawnscanner", "kb", "kb.yaml")
    next if File.file?(kb_yaml)

    kb_dir = File.dirname(kb_yaml)
    mkdir_p kb_dir
    archive = File.join(Dir.tmpdir, "dawn-kb-#{DAWN_KB_VERSION}.tar.gz")
    sh "curl -fsSL -o #{archive} #{DAWN_KB_URL}"
    sh "tar -xzf #{archive} -C #{kb_dir}"
  end

  desc "Run bundler-audit and Dawnscanner against this Hanami app"
  task check: :dawn_kb do
    sh "bundle exec bundler-audit check --update"
    sh "bundle exec dawn scan ."
  end
end
