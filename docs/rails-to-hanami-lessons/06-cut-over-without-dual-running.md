# Lesson 06 — Cut over without dual-running

**Runtime:** 10 minutes  
**Pair with:** this PR and Railway project `ebwiki-hanami-staging`

## The trap

`bin/one-site` proxies Hanami `:2300` and Rails `:3001` onto `:3000`. That is
a fine local debugging tool. It is a bad hosting plan. You pay for two apps,
two deploys, and a shared-cookie problem you never solve.

## The cut we can do now

| Keep running | Sleep / stop |
| --- | --- |
| `hanami-web` on Railway | `ebwiki-web`, `ebwiki-maps` Rails previews |
| One Railway Postgres for Hanami | Duplicate `hanami` service with no git source |
| Heroku Rails `ebwiki.org` until mail + S3 land | Extra preview Redis / crashed query jobs |

Production DNS does not move in this lesson. Taking down `ebwiki.org` to prove
a framework point would be malpractice.

## Teaching point

"Minimize two services" means one public wiki process. It does not mean
delete the production database.

## Video beats

1. Railway dashboard: four EBWiki projects. Count the web services.
2. After this PR: one Hanami URL for cases, map, and photo review.
3. Say what is still Rails-only: outbound mail, new S3 objects, `ebwiki.org`.

## Exercise

Write the cutover checklist you would hand a maintainer at 9pm. Include the
line: never copy Heroku `DATABASE_URL` into Railway.
