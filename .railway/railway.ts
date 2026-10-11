import { defineRailway, project, service } from "railway/iac";

// Own only the staging web service; Postgres and Redis stay out of this partial.
export const partial = "ebwiki-staging";

export default defineRailway(() => {
  const ebwiki = service("ebwiki", {
    env: {
      RAILWAY_DOCKERFILE_PATH: "Dockerfile.railway",
    },
    preDeploy:
      "doppler run --project ebwiki --config stg -- bash release-tasks.sh",
    start:
      "doppler run --project ebwiki --config stg -- bundle exec puma -C config/puma.rb",
    healthcheck: "/up",
    healthcheckTimeout: 300,
  });

  return project("ebwiki", {
    resources: [ebwiki],
  });
});
