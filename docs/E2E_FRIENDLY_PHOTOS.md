# Friendly photo e2e results and gaps

This is what the Capybara and Playwright suites confirm, and what they
cannot yet prove.

## Confirmed behavior

- Guests cannot open `/friendly_photos`; they are sent to login.
- Signed-in editors see a **Profile pictures** item in the desktop header.
- The default list includes cases with no photo or a photo that needs
  replacement, and excludes cases that already have a profile picture
  filename.
- Filters for no photo yet, needs a healthier photo, and has a profile
  picture work.
- A case show page offers **Find a profile picture** only when the case
  still needs one.
- The case edit form exposes photo type and a Wikimedia search link.
- Editors can classify the current photo without uploading a new file.
- Unsuitable candidates show a warning and have no **Use this photo**
  button.
- Rejecting a pending candidate removes the apply action.
- Applying a reviewed photo marks the case as a profile picture and hides
  **Use this photo**. Unsuitable candidates stay flagged and cannot be
  applied.
- Search persists Wikimedia and Openverse stub candidates. In CI that
  search is stubbed. An unsuitable-only result shows **None found**.
- Operators can find a case by name, location, date, or id.

## Gaps the e2e run surfaces

1. **Real Wikimedia and CarrierWave apply are stubbed in CI only.**
   Playwright sets `E2E_STUB_WIKIMEDIA=1`. The Railway preview
   (`https://ebwiki-web-production.up.railway.app/friendly_photos`) uses
   `E2E_STUB_WIKIMEDIA=0` and `OPENAI_API_KEY` for live Commons / enwiki /
   Openverse plus SearchPlanner/VisionClassifier.
2. **Followers are not emailed** when a portrait is applied. Apply goes
   through `FriendlyPhotos::ApplyCandidate`, not `CasesController#update`,
   so `CaseMailer.send_followers_email` never runs.
3. **Suitability detection is metadata-only.** An institutional photo
   whose title is "portrait" would not be flagged. There is no pixel-level
   check.
4. **Mobile nav hides the workflow.** On a phone-sized viewport the
   Profile pictures link is inside the collapsed Bootstrap menu. Editors
   have to open the hamburger first. Apply, reject, and search are also
   hard to tap on a phone: the fixed header and stacked candidate cards
   intercept hits. Those mutations are covered on desktop Chromium.
5. **Confirm dialogs need JavaScript.** Search and apply use
   `data-confirm` via jquery_ujs. Without JS the request still submits.
6. **Classify skips the edit summary.** Photo type is saved with
   `update_column`, so PaperTrail does not get a human summary.
7. **Multi-subject cases show one name.** The index and show pages use
   `subjects.first`. A second victim is searched but not labeled in the
   list.
8. **Wikimedia outages have no editor-facing error.** A failed live
   search currently looks like "no candidates yet".
9. **Admin candidate audit is separate.** `/admin/photo_candidates` is
   not linked from the editor workflow.
10. **The case edit form still has a stray `<<div`.** That is older
    markup, but Playwright will see it on the edit page.
11. **No-photo and needs-healthier-photo filters overlap.** A case marked
    as needing a healthier photo with no stored file still appears under
    **No photo yet**, because that filter only checks the avatar column.

## Suggested follow-ups

- Notify followers when a case photo is replaced.
- Show a flash when Wikimedia returns an error or zero hits.
- Add a mobile entry point that does not depend on the hamburger, and
  give apply/reject/search larger tap targets below the fixed header.
- Keep the no-photo filter from also listing cases that need a healthier
  photo but have no stored file, or document that overlap in the UI.
- Run one staging apply against a real Commons portrait before relying
  on the workflow in production.

## GitHub Actions quota

Capybara in the main CI workflow is the every-PR check. Playwright is a
separate **E2E** workflow so browser minutes stay bounded:

- Runs on a PR only when friendly-photo UI, e2e fixtures, or
  `.github/workflows/e2e.yml` change
- Pull requests use desktop Chromium only (`E2E_SUITE=smoke`)
- The full Pixel 5 suite runs weekly and on manual dispatch
- Newer pushes cancel in-progress runs
- Elasticsearch is not started; browsers, gems, and npm are cached
- Failure artifacts expire after 3 days

See `e2e/README.md` for how to run the same suites locally.
