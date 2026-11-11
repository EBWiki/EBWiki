# frozen_string_literal: true

require 'rails_helper'

# Deploy commands run on every staging and production deploy. A seed, reset or
# sample-data step there silently changes real case data (GKT-1816).
RSpec.describe 'deploy commands' do
  forbidden = /db:(seed|reset|setup|prepare|drop|purge|schema:load|structure:load)|staging:sample_content/

  %w[release-tasks.sh Procfile railway.toml .railway/railway.ts].each do |path|
    it "#{path} has no seed, reset or sample-data step" do
      full = Rails.root.join(path)
      skip "#{path} not present" unless File.exist?(full)

      commands = File.readlines(full).reject { |line| line.strip.start_with?('#', '//') }.join
      expect(commands).not_to match(forbidden)
    end
  end

  it 'protects staging and production from destructive database tasks' do
    expect(Rails.application.config.active_record.protected_environments).to include('production', 'staging')
  end
end
