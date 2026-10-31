# frozen_string_literal: true

require 'open3'

module StagingAssetHostHelper
  module_function

  def configured_asset_host(asset_host_env:, redis_url:)
    stdout, stderr, status = run_staging_runner(asset_host_env:, redis_url:)
    raise_runner_failure(status, stderr, stdout) unless status.success?

    parse_configured_host(stdout)
  end

  def run_staging_runner(asset_host_env:, redis_url:)
    child_env = staging_child_env(asset_host_env, redis_url)
    Open3.capture3(
      child_env,
      'bundle', 'exec', 'rails', 'runner', runner_script,
      chdir: Rails.root.to_s
    )
  end

  def staging_child_env(asset_host_env, redis_url)
    child_env = StagingEnvironmentBoot.staging_boot_env(redis_url)
    if asset_host_env.nil?
      child_env.delete('ASSET_HOST')
    else
      child_env['ASSET_HOST'] = asset_host_env
    end
    child_env['NEW_RELIC_AGENT_ENABLED'] = 'false'
    child_env
  end

  def parse_configured_host(stdout)
    stdout.each_line do |line|
      stripped = line.strip
      next unless stripped.start_with?('CONFIGURED_HOST=')

      return stripped.delete_prefix('CONFIGURED_HOST=')
    end

    raise "staging config runner did not emit CONFIGURED_HOST: #{stdout}"
  end

  def raise_runner_failure(status, stderr, stdout)
    raise "staging config runner failed (exit #{status.exitstatus}): #{stderr}\n#{stdout}"
  end

  def runner_script
    <<~RUBY
      configured = Rails.application.config.action_controller.asset_host
      puts "CONFIGURED_HOST=\#{configured.nil? ? 'nil' : configured}"
    RUBY
  end
  private_class_method :runner_script, :raise_runner_failure
end
