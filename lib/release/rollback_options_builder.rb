# frozen_string_literal: true

require_relative 'plain'
require_relative 'rollback/staging_context'
require_relative 'rollback/previous_deployment_resolver'

module Release
  # Builds RollbackOptions from argv and environment variables.
  class RollbackOptionsBuilder
    ALLOWED_FLAGS = %w[--execute --yes].freeze
    DEFAULT_PLATFORM = 'railway'
    DEFAULT_SERVICE = Release::Rollback::StagingContext::DEFAULT_SERVICE
    DEFAULT_ENVIRONMENT = Release::Rollback::StagingContext::DEFAULT_ENVIRONMENT

    def self.from_argv(argv, staging_context: Rollback::StagingContext.new,
                       deployment_resolver: Rollback::PreviousDeploymentResolver.new)
      new(argv, staging_context: staging_context, deployment_resolver: deployment_resolver).build
    end

    def initialize(argv, staging_context:, deployment_resolver:)
      @argv = argv
      @staging_context = staging_context
      @deployment_resolver = deployment_resolver
    end

    def build
      reject_unknown_flags!

      RollbackOptions.new(**options_hash)
    end

    private

    def options_hash
      flags = parse_flags(@argv)
      platform = Plain.env_presence('RELEASE_ROLLBACK_PLATFORM') || DEFAULT_PLATFORM
      service_name = Plain.env_presence('RAILWAY_SERVICE') || DEFAULT_SERVICE
      environment_slug = Plain.env_presence('RAILWAY_ENVIRONMENT') || DEFAULT_ENVIRONMENT
      {
        platform: platform,
        service_name: service_name,
        deployment_id: resolve_deployment_id(service_name, environment_slug),
        environment_slug: environment_slug,
        dry_run: flags[:dry_run],
        skip_confirm: flags[:skip_confirm]
      }
    end

    def resolve_deployment_id(service_name, environment_slug)
      explicit = Plain.env_presence('RAILWAY_ROLLBACK_DEPLOYMENT_ID')
      return explicit if Plain.present?(explicit)

      token = Plain.env_presence('RAILWAY_TOKEN')
      return nil if Plain.blank?(token)

      ids = @staging_context.ids_for!(
        token: token,
        service_name: service_name,
        environment_name: environment_slug
      )
      @deployment_resolver.resolve!(
        token: token,
        project_id: ids.fetch(:project_id),
        service_id: ids.fetch(:service_id),
        environment_id: ids.fetch(:environment_id)
      )
    end

    def reject_unknown_flags!
      unknown = @argv.select { |arg| arg.start_with?('--') && ALLOWED_FLAGS.include?(arg) == false }
      raise RollbackError, "Unknown flag #{unknown.first}" if unknown.any?
    end

    def parse_flags(argv)
      argv.each_with_object(default_flags) do |arg, memo|
        case arg
        when '--execute' then memo[:dry_run] = false
        when '--yes' then memo[:skip_confirm] = true
        end
      end
    end

    def default_flags
      { dry_run: true, skip_confirm: false }
    end
  end
end
