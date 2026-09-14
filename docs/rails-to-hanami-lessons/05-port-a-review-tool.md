# Lesson 05 — Port a review tool, not a gem

**Runtime:** 15 minutes  
**Pair with:** `app/services/friendly_photos/` (Rails #4407) and
`apps/hanami/lib/eb_wiki/friendly_photos/`

## Product lock (do not re-ask)

From GKT-182:

1. Start with the person’s name.
2. Then search for a photo.
3. Sources only: Wikimedia Commons, English Wikipedia, Openverse.
4. No mugshot farms. Human review before publish.

## Rails

Twenty-plus service objects: planner, AI client, vision classifier,
Wikimedia client, Openverse client, persist-to-`photo_candidates`. That is a
good Rails preview. It is too much to copy line-for-line on day one of Hanami.

## Hanami

Three files:

- `SourcePolicy` — same host allow/deny list
- `CandidateSearch` — name-first query, stubbed in tests
- Actions + views at `/friendly_photos`

We did not port S3 apply. Attaching a new avatar still waits on the upload
slice. The teachable win is the review UI, not the CarrierWave writer.

## Teaching point

When a Rails feature is a pile of POROs, Hanami does not need a new framework
idea. Put the POROs in `lib/`. Keep HTTP in actions. Keep SQL in repos.

`E2E_STUB_WIKIMEDIA=1` is the same seam Rails used. Tests never hit the
network.

## Video beats

1. Open `/friendly_photos`. Click Walter Scott.
2. Show a family portrait and a flagged booking photo.
3. Open `SourcePolicy` and read the blocked host list out loud.

## Exercise

Add English Wikipedia page extracts under each candidate without adding a gem.
Use `Net::HTTP`. That is the whole point.
