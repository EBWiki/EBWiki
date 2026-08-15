# Friendly photo search

EBWiki case pages should show a dignified photo of the person whenever one
exists. The case form already asks editors to look beyond mugshots. This
workflow searches the people already in the EBWiki database and looks for
friendly portraits.

A friendly photo is a family picture, portrait, yearbook image, or other
non-carceral photo. Mugshots, booking photos, inmate-lookup images, and
jail or prison identification photos are excluded.

Nothing is published automatically. A person always reviews the candidates.

## In the app

Signed-in editors can:

1. Open **Friendly photos** in the header, or open a case and choose
   **Search Wikimedia for a friendly photo** on the edit form.
2. Filter cases that are missing a photo, marked as a mugshot, or still
   unclassified.
3. Run a Wikimedia Commons and Wikipedia search for that person.
4. Reject anything that still looks like a mugshot.
5. Apply a reviewed portrait, or upload a better file on the case edit form.
6. Mark the current photo as **Portrait**, **Mugshot**, or **Other**.

The search only keeps HTTPS images hosted on Wikimedia. That keeps the
results openly licensed and avoids inmate-lookup or mugshot-farm sites.

## Agent routine

Use this when an agent should walk the database and propose replacements
instead of clicking through the UI.

1. Load cases that still need a better photo:

   `Case.needing_friendly_photo`

   That includes missing avatars, unclassified photos, and photos already
   marked as mugshots.

2. Optionally classify current filenames first:

   `bundle exec rake photos:classify_current`

   This only looks at the stored avatar path. Names such as `booking.jpg`
   or `mugshot.png` are marked as mugshots. It does not change the image.

3. Search one case or a small batch:

   `bundle exec rake photos:search_friendly CASE=walter-scott`

   `bundle exec rake photos:search_friendly LIMIT=10 FORMAT=json`

4. Read the JSON or the saved `photo_candidates` rows. Drop any result
   whose `likely_mugshot` flag is true, or whose title, filename, or
   description mentions booking, inmate, jail, prison, or mugshot.

5. Present the remaining portraits to a human reviewer with the license,
   author, and source page. Do not apply a photo from an agent run.

6. After a person accepts a candidate, apply it in the app or by calling
   `FriendlyPhotos::ApplyCandidate` for that case and candidate.

## Rules

- Search only Wikimedia Commons and English Wikipedia.
- Do not scrape social networks, news sites, or booking-photo databases.
- Do not apply a candidate without a human review.
- Prefer a family or community portrait over an incident or protest photo.
- Keep the Wikimedia license and source page with the candidate.
- If no friendly photo is found, leave the case unchanged.
