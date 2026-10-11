import {
  defineRailway,
  github,
  preserve,
  project,
  service,
} from "railway/iac";

// Own only the staging web service deploy settings; Postgres and Redis stay out of this partial.
// GitHub source matches OpenTofu (infra/staging/railway.tf). Variable values stay on Railway / OpenTofu.
export const partial = "ebwiki-staging";

const GITHUB_REPO = "EBWiki/EBWiki";
const GITHUB_BRANCH = "main";

/** Public name list only (no values). Keep in sync with live staging service variables. */
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
  "RAILWAY_DOCKERFILE_PATH",
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
      dockerfilePath: "Dockerfile.railway",
    },
    env: preservedEbwikiEnv(),
    preDeploy:
      "doppler run --project ebwiki --config stg -- bash release-tasks.sh",
    start:
      "doppler run --project ebwiki --config stg -- bundle exec puma -C config/puma.rb",
    healthcheck: "/up",
    healthcheckTimeout: 300,
    deploy: {
      preDeployTimeoutSeconds: 900,
      restartPolicyType: "ON_FAILURE",
      restartPolicyMaxRetries: 3,
    },
  });

  return project("ebwiki", {
    resources: [ebwiki],
  });
});
