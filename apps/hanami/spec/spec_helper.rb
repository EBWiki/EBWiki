# frozen_string_literal: true

require "pathname"
SPEC_ROOT = Pathname(__dir__).realpath.freeze

ENV["HANAMI_ENV"] ||= "test"

manifest = SPEC_ROOT.join("../public/assets/assets.json")
unless manifest.file?
  Dir.chdir(SPEC_ROOT.join("..")) do
    system("npm", "install", "--silent") or raise "npm install failed"
    system("bundle", "exec", "hanami", "assets", "compile") or raise "hanami assets compile failed"
  end
end

require "hanami/prepare"

SPEC_ROOT.glob("support/**/*.rb").each { |f| require f }
