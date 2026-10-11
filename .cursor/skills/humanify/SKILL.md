---
name: Humanify
description: >-
  Mandatory before any agent writes text a person will read: PR titles and
  bodies, commit messages, Linear titles and comments, repo docs, digests,
  reports, chat replies, and client or site copy. The writer runs this
  self-check on its own text before posting. Outbound email and messages still
  need the outbound send check afterward.
---
# Humanify

Every agent checks its own text with this skill before the text is posted, pushed, or sent. There is no handoff to another bot for ordinary writing. If you wrote it and a person will read it, run these steps first.

## When
- PR titles and PR bodies (including updates to them)
- Commit messages and any title a reviewer sees in a list
- Linear issue titles, descriptions, and comments
- Repo docs (README, AGENTS.md, guides), digests, reports, journals
- Chat replies and status updates
- Client copy, site copy, proposals, briefs

## Steps
1. **Plain-English test.** Read the text as a smart reader who was not in the conversation. If any word or phrase would make them stop and ask what it means, rewrite it.
2. **Coined labels.** Cut internal nicknames that stand in for a description ("GO ledger", "merge train", "oracle-red", "echo wake", "zombie ticket", "refill burst", "slice 5b"). Say what the thing is.
3. **Acronyms.** Spell out or replace anything the reader may not know (WIP, SoT, CA, DoD, AC, RCA, L&F). "PR" is fine for engineers; say "pull request" for anyone else.
4. **Tool-speak.** Replace with plain words: tip or tip SHA, blob, stub, slot, hard-close, fail closed, no-op, second-source verify. See the table below.
5. **Symbols and punctuation.** No em dashes. No arrows (the right-arrow character or "->"). No `label: value` fragments in place of sentences. No stacked slashes (a/b/c) where a sentence works. Prefer periods, commas, parentheses, and short sentences.
6. **IDs and hashes.** Keep an ID only when the reader needs it to act (a PR link, a ticket number in the body). Drop commit hashes, file-version ids, and internal comment ids from anything a person reads; leave them in machine logs.
7. **AI filler and cadence.** Cut "certainly", "I'd be happy to", "in order to", "leverage", "robust", "seamless", "delve", stacked adjectives, fake warmth, cardboard openers ("I'm [name] in [city]"), headline fragments, and restated questions. Do not soften a no.
8. **Decision words.** For an owner's decisions write GO, approved, settled, or decided. Never "locked".
9. **Facts stay put.** Keep names, prices, dates, and wording the owner already approved. Do not invent or round. If you did not check something, say so.
10. **Design notes stay off the page.** Site and flyer copy talks to the audience. Palette names, design direction names, and craft notes never appear as page content.

## Titles
- **PR titles: say what changes for the site or its users.** Write it so a non-engineer understands it from the PR list.
  - Bad: "Guard slice 5b case avatar column drop when Active Storage photos are missing"
  - Good: "Don't delete the old case photo column while some cases still haven't moved their photo"
- No class names, migration names, method names, slice or phase numbers, or ticket jargon in the title. Put the ticket number in the body, not the title.
- Commit messages and Linear titles follow the same rule. Report and doc titles read as plain English: "EBWiki open PR merge order report", not "open-draft merge-GO ledger".
- Existing branch and file names can stay. Fix the human-facing title.

## PR bodies
- Open with a plain-English summary: what changes, who it affects, and why.
- Technical detail (class names, migrations, commands, file paths) belongs in the test plan, deployment plan, and rollback plan sections, not in the title or summary.
- A command or product name that is truly needed goes in a code span and is explained once in plain words.

## Before you post
Re-read the final text once more, start to finish, against steps 1 to 8. If anything fails, rewrite and check again. Then post.

## Send gate
This self-check does not clear outbound email, texts, or chat messages to people outside the team. Those still go through the outbound send check (CLEAR or REJECT) and the owner's explicit send approval. Passing this skill is never permission to send.

## Banned terms
Keep this list current. When the owner flags a term as jargon, add it with its plain replacement.

| Term | Say instead |
| --- | --- |
| GO ledger / merge-GO ledger | list of open PRs and the order to merge them |
| merge train | merge order |
| WIP / WIP cap | running agents / limit on running agents |
| SoT | main copy, source of truth |
| CA | cloud agent |
| DoD | definition of done |
| AC | acceptance criteria |
| L&F | look and feel |
| tip, tip SHA | latest commit |
| blob | file version |
| stub | placeholder |
| slot | room for one more agent |
| hard-close | final check and close |
| fail closed | stop and block if unsure |
| second-source verify | double-checked in a second place |
| no-op | no change needed |
| echo wake | follow-up run |
| oracle-red | failing check |
| locked (for decisions) | GO, approved, settled |
| slice N, phase N, wave N (in titles) | describe the change itself |
| class, method, or migration names (in titles) | what changes for the site or its users |
| em dash, arrows | period, comma, or a short sentence |
| in order to | to |
| leverage, robust, seamless | plain verbs and specifics |
| bootstrap (in titles and summaries) | one-time setup, first-time infrastructure setup |
| token maker (in titles and summaries) | automated Cloudflare API access setup |
| two-stage R2 (in titles and summaries) | describe the steps in the deployment plan instead |
| Doppler project or secret names in titles and summaries | "secrets store", "deploy secrets"; names only in deployment or rollback sections |
| GKT-#### in titles and summaries | one line: "Tracked privately: …" at the end of the summary |
