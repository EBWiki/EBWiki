# frozen_string_literal: true

require 'open3'

# Boots a fresh Rails process with RAILS_ENV=staging and exercises Rails.cache.
module StagingEnvironmentBoot
  SUCCESS_MARKER = 'STAGING_CACHE_BOOT_OK'

  class BootError < StandardError; end

  module_function

  def cache_round_trip!(redis_url:)
    child_env = ENV.to_h.merge(staging_boot_env(redis_url))
    stdout, stderr, status = Open3.capture3(
      child_env,
      'bundle', 'exec', 'rails', 'runner', runner_script,
      chdir: Rails.root.to_s
    )

    return if status.success? && stdout.include?(SUCCESS_MARKER)

    report_boot_failure(status, stdout, stderr)
    raise BootError, boot_failure_message(status, stdout, stderr)
  end

  def staging_boot_env(redis_url)
    {
      'RAILS_ENV' => 'staging',
      'REDIS_URL' => redis_url,
      'SECRET_KEY_BASE' => 'ci_staging_cache_boot_only',
      'PT_SILENCE_AR_COMPAT_WARNING' => 'true',
      'NEW_RELIC_LICENSE_KEY' => 'ci_staging_cache_boot',
      'DISABLE_SPRING' => '1'
    }
  end

  def runner_script
    <<~RUBY
      key = "staging_cache_smoke_\#{SecureRandom.hex(8)}"
      wrote = Rails.cache.write(key, 'ok', expires_in: 60.seconds)
      unless wrote
        Rails.logger.error({ event: 'staging_cache_write_failed', key: key }.to_json)
        abort('staging cache write returned false')
      end

      read_back = Rails.cache.read(key)
      unless read_back == 'ok'
        Rails.logger.error(
          { event: 'staging_cache_read_failed', key: key, value: read_back.inspect }.to_json
        )
        abort("staging cache read mismatch: \#{read_back.inspect}")
      end

      Rails.cache.delete(key)
      puts '#{SUCCESS_MARKER}'
    RUBY
  end

  def report_boot_failure(status, stdout, stderr)
    payload = {
      event: 'staging_environment_boot_failed',
      exitstatus: status.exitstatus,
      stdout: stdout.lines.last(5).join.strip,
      stderr: stderr.lines.last(5).join.strip
    }
    Rails.logger.error(payload.to_json)
    notify_rollbar_boot_failure(status.exitstatus)
  end

  def notify_rollbar_boot_failure(exitstatus)
    return unless defined?(Rollbar)

    Rollbar.error('Staging environment cache boot failed', exitstatus: exitstatus)
  end

  def boot_failure_message(status, stdout, stderr)
    [
      "Staging environment cache boot failed (exit #{status.exitstatus}).",
      "stderr: #{stderr}",
      "stdout: #{stdout}"
    ].join(' ')
  end
  private_class_method :report_boot_failure, :boot_failure_message, :notify_rollbar_boot_failure
end
