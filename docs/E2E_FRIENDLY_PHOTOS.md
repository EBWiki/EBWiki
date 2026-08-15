# Friendly photo e2e results and gaps

This is what the Capybara and Playwright suites confirm, and what they
cannot yet prove.

## Confirmed behavior

- Guests cannot open `/friendly_photos`; they are sent to login.
- Signed-in editors see a **Friendly photos** item in the desktop header.
- The default list includes missing and mugshot cases, and excludes cases
  already marked as a portrait with a stored filename.
- Filters for missing, mugshot, and portrait cases work.
- A case show page offers **Find a friendly photo** only when the case
  still needs one.
- The case edit form exposes photo type and a Wikimedia search link.
- Editors can classify the current photo without uploading a new file.
- Mugshot candidates show a warning and have no **Use this photo** button.
- Rejecting a pending candidate removes the apply action.
- Applying a reviewed portrait marks the case as a portrait and hides
  **Use this photo**. Mugshot candidates stay flagged and cannot be applied.
- Search persists candidates. In CI that search is stubbed.

## Gaps the e2e run surfaces

1. **Real Wikimedia and CarrierWave apply are stubbed.** Playwright sets
   `E2E_STUB_WIKIMEDIA=1`, so CI does not download a remote image or talk
   to Commons. A staging pass against live Wikimedia is still needed.
2. **Followers are not emailed** when a portrait is applied. Apply goes
   through `FriendlyPhotos::ApplyCandidate`, not `CasesController#update`,
   so `CaseMailer.send_followers_email` never runs.
3. **Mugshot detection is metadata-only.** A booking photo whose title is
   "portrait" would not be flagged. There is no pixel-level check.
4. **Mobile nav hides the workflow.** On a phone-sized viewport the
   Friendly photos link is inside the collapsed Bootstrap menu. Editors
   have to open the hamburger first. Playwright also saw the Wikimedia
   search button sit under candidate cards on a phone-sized viewport.
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
11. **Missing and mugshot filters overlap.** A case marked mugshot with
    no stored file still appears under **Missing photo**, because that
    filter only checks the avatar column.

## Suggested follow-ups

- Notify followers when a case photo is replaced.
- Show a flash when Wikimedia returns an error or zero hits.
- Add a mobile entry point that does not depend on the hamburger.
- Keep the missing-photo filter from also listing mugshot cases that
  have no stored file, or document that overlap in the UI.
- Run one staging apply against a real Commons portrait before relying
  on the workflow in production.
