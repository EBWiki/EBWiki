# EBWiki Code Quality & Software Engineering Rules

---

## 1. Pre-commit & CI

- **Run checks before pushing:** `bundle exec pre-commit install` — rubocop, brakeman, and rspec run on every commit.
- **Fix failures locally:** Do not push if rubocop, brakeman, or rspec fail. Use `git commit -n` only for exceptional WIP commits.
- **CI must pass:** PRs require green CI (rspec, rubocop, brakeman, markdown-link-checker).

## 2. Code Style (Rubocop)

- **No new offenses:** All new and modified code must pass rubocop. Do not add `rubocop:disable` without a tracked issue.
- **Line length:** Max 100 characters.
- **Block length:** Max 35 lines per block; extract methods or classes when exceeded.
- **Address todos:** Prefer fixing `rubocop:todo` items over adding new ones.

## 3. Testing

- **Spec new behavior:** New features, services, and non-trivial changes require specs.
- **Fix broken specs:** Do not commit with failing specs. Fix or skip with `xit` and a comment only when justified.
- **Isolation:** Specs must be independent; avoid order-dependent tests.
- **Factories over fixtures:** Use FactoryBot for test data.

## 4. Architecture & Design

- **Service objects:** Extract business logic into `app/services` classes that `include Service` and implement `call(...)`.
- **Thin controllers:** Controllers handle HTTP; delegate to services, models, or queries.
- **Single responsibility:** One clear purpose per class/module.
- **Explicit over implicit:** Prefer clear, readable code over clever shortcuts.

## 5. Security

- **Brakeman:** No new security warnings. Address or document any existing warnings before adding more.
- **Strong params:** Use `permit` for all user input; never mass-assign from params without explicit allowlist.
- **Sensitive data:** No secrets, API keys, or credentials in code or logs.

## 6. Error Handling

- **Specific rescues:** Rescue specific exception types; avoid `rescue StandardError` unless necessary, and log.
- **Fail fast:** Raise on invalid state; do not swallow errors silently.
- **Logging:** Log errors with context (e.g., Rollbar) for production debugging.

## 7. Git & PRs

- **Branch per feature/fix:** Work on a branch; do not commit directly to main.
- **Focused PRs:** One logical change per PR; keep diffs reviewable.
- **Meaningful commits:** Clear, present-tense commit messages (e.g., "Add pre-commit hooks for rubocop").
- **Link issues:** Reference issues/PRs in commit messages when relevant (e.g., "Closes #4319").

## 8. Documentation

- **Update docs:** When behavior changes, update DEVELOPMENT.md, README, or relevant docs.
- **Comments:** Explain *why*, not *what*; avoid redundant comments.
- **Public APIs:** Document non-obvious public methods, especially in services and lib.

## 9. Dependencies & Maintenance

- **Minimal new deps:** Add gems only when necessary; prefer stdlib or existing deps.
- **Version pins:** Use `~>` for minor/patch flexibility; pin major when stability matters.
- **Dependabot:** Review and merge security updates promptly.

## 10. General Principles

- **DRY:** Don't repeat yourself; extract shared logic.
- **YAGNI:** You aren't gonna need it; avoid speculative complexity.
- **Readability:** Code is read more than written; optimize for clarity.
- **No silent failures:** Avoid empty rescues, ignored return values, or hidden side effects.

---

## Summary Checklist (Before Submitting a PR)

- [ ] `bundle exec rubocop` passes
- [ ] `bundle exec brakeman` shows no new warnings
- [ ] `bundle exec rspec` passes
- [ ] New code has specs where appropriate
- [ ] No new `rubocop:disable` without an issue
- [ ] Docs updated if behavior changed
- [ ] Commit messages are clear and reference issues when relevant
