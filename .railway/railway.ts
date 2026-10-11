import { defineRailway, project, service } from "railway/iac";

// Own only the staging web service deploy settings; Postgres and Redis stay out of this partial.
// Service variables (DATABASE_URL, DOPPLER_TOKEN, RAILWAY_DOCKERFILE_PATH, etc.) are managed by OpenTofu / Railway references — not IaC.
export const partial = "ebwiki-staging";

export default defineRailway(() => {
  const ebwiki = service("ebwiki", {
    preDeploy:
      "doppler run --project ebwiki --config stg -- bash release-tasks.sh",
    start:
      "doppler run --project ebwiki --config stg -- bundle exec puma -C config/puma.rb",
    healthcheck: "/up",
    healthcheckTimeout: 300,
    deploy: {
      restartPolicyType: "ON_FAILURE",
      restartPolicyMaxRetries: 3,
    },
  });

  return project("ebwiki", {
    resources: [ebwiki],
  });
});
