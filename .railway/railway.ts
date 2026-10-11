import {
  defineRailway,
  github,
  preserve,
  project,
  service,
} from "railway/iac";

// Staging ebwiki web service: source, build, and deploy settings. Postgres/Redis are other partials.
export const partial = "ebwiki-staging";

const GITHUB_REPO = "EBWiki/EBWiki";
const GITHUB_BRANCH = "main";
const DOCKERFILE_PATH = "Dockerfile.railway";

/** Public name list only (no secret values). Keep in sync with live staging service variables. */
const EBWIKI_PRESERVED_VARIABLE_NAMES = [
  "AWS_ACCESS_KEY_ID",
  "AWS_SECRET_ACCESS_KEY",
  "AWS_SECRET_KEY_ID",
  "DATABASE_URL",
  "DOPPLER_TOKEN",
  "HTTP_BASIC_AUTH_ENABLED",
  "HTTP_BASIC_AUTH_PASSWORD",
  "HTTP_BASIC_AUTH_USERNAME",
  "MAILCHIMP_LINK",
  "MALLOC_ARENA_MAX",
  "NEWRELIC_AGENT_ENABLED",
  "NEW_RELIC_AGENT_ENABLED",
  "NEW_RELIC_MONITOR_MODE",
  "RACK_ENV",
  "RAILS_ENV",
  "RAILS_LOG_TO_STDOUT",
  "RAILS_SERVE_STATIC_FILES",
  "REDIS_URL",
  "REVIEW_SERVER",
  "S3_BUCKET",
  "SECRET_KEY_BASE",
  "STAGING_PASSWORD",
  "STAGING_USERNAME",
] as const;

function preservedEbwikiEnv() {
  return Object.fromEntries(
    EBWIKI_PRESERVED_VARIABLE_NAMES.map((name) => [name, preserve()]),
  );
}

export default defineRailway(() => {
  const ebwiki = service("ebwiki", {
    source: github(GITHUB_REPO, { branch: GITHUB_BRANCH }),
    build: {
      builder: "DOCKERFILE",
    },
    env: {
      ...preservedEbwikiEnv(),
      // Dockerfile path via Railway variable only (not build.dockerfilePath) to avoid plan drift.
      RAILWAY_DOCKERFILE_PATH: DOCKERFILE_PATH,
    },
    preDeploy:
      "doppler run --project ebwiki --config stg -- bash release-tasks.sh",
    start:
      "doppler run --project ebwiki --config stg -- bundle exec puma -C config/puma.rb",
    healthcheck: "/up",
    healthcheckTimeout: 300,
    deploy: {
      preDeployTimeoutSeconds: 900,
      overlapSeconds: 0,
      drainingSeconds: 0,
      restartPolicyType: "ON_FAILURE",
      restartPolicyMaxRetries: 3,
    },
  });

  return project("ebwiki", {
    resources: [ebwiki],
  });
});
