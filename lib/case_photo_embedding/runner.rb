# frozen_string_literal: true

require 'open3'

module CasePhotoEmbedding
  # Runs the SigLIP CPU embedding job (Python) and reports structured results.
  class Runner
    PYTHON_PACKAGE = Rails.root.join('lib/case_photo_embedding/python').freeze

    def initialize(logger: Rails.logger, env: ENV.to_h)
      @logger = logger
      @env = env
    end

    def call
      logger.info('[CasePhotoEmbedding] starting embed job')
      stdout, stderr, status = Open3.capture3(job_env, *command)
      log_process_output(stdout, stderr)
      raise_on_failure!(status, stderr)
      summary = parse_summary(stdout)
      logger.info("[CasePhotoEmbedding] finished #{summary}")
      summary
    end

    private

    attr_reader :logger, :env

    def command
      [
        'python3', '-m', 'case_photo_embedding.job'
      ]
    end

    def job_env
      base = env.slice('DATABASE_URL', 'RAILS_ENV', 'HF_HOME', 'TRANSFORMERS_CACHE')
      base.merge(
        'PYTHONPATH' => PYTHON_PACKAGE.to_s,
        'CASE_PHOTO_EMBEDDING_MODEL' => model_id
      )
    end

    def model_id
      env.fetch('CASE_PHOTO_EMBEDDING_MODEL', 'google/siglip2-base-patch16-224')
    end

    def log_process_output(stdout, stderr)
      stdout.each_line { |line| logger.info("[CasePhotoEmbedding] #{line.chomp}") }
      stderr.each_line { |line| logger.warn("[CasePhotoEmbedding] #{line.chomp}") }
    end

    def raise_on_failure!(status, stderr)
      return if status.success?

      error = EmbedJobFailed.new("embed job exited #{status.exitstatus}")
      ErrorReporter.report(error, stderr: stderr.lines.last(5).join)
      raise error
    end

    def parse_summary(stdout)
      JSON.parse(stdout.lines.last, symbolize_names: true)
    end

    class EmbedJobFailed < StandardError; end
  end
end
