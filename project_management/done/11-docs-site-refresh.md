# Documentation and site refresh

## Metadata
- **Type:** Chore
- **Appetite:** 2 days
- **Status:** Done (2026-09-23)
- **Created:** 2026-09-23
- **Breaking:** no

## Problem
- The site loads docsify 4.12.1 from unpkg, with every plugin **unpinned** from unpkg, so a
  plugin's major release can break the site at any time with no commit here.
- It reports to Google Analytics `UA-131259352-1`. Universal Analytics was shut down in 2023,
  so the tag collects nothing.
- Three docs domains are in circulation: `firefueldocs.com` (CNAME, pubspec),
  `firefueldocs.dev` (root README) and `firefuel.dev` (package README).
- The Getting Started pubspec snippet pins `cloud_firestore: ^4.3.2` and `firefuel: ^0.3.2`.
- In Core Concepts, `Left(Failure(e, ...))` constructs an abstract class.
- Architecture promises a tutorial section that doesn't exist.

## Criteria
### Must have
- Pin every script to an exact version from jsDelivr. Upgrade to the current docsify.
  Remove the dead analytics tag.
- One domain everywhere: `firefueldocs.com`, the one CNAME serves.
- Every snippet matches the current API. Every new feature has a section in the API guide.
- A migration guide for 0.5.
- `READINGS.md` records when each front-door doc was last read whole.

### Out of scope
- Moving off docsify (for example to a static site generator). Not warranted; docsify serves
  from `/docs` with no build step, and that's why a push to main deploys it.

## Outcome (2026-09-23)
Shipped in `4da3b27`: docsify 5.0.0 with pinned assets; the dead analytics tag, abandoned
plugins and never-registered `sw.js` removed; a site home page; the migration guide; the API
guide rewritten. Rendered locally in headless Chrome (home, API guide, migration).
**Open, needs the maintainer:** `https://firefueldocs.com` serves GitHub's `*.github.io`
certificate, so HTTPS fails with a name mismatch; HTTP works. Re-provision the certificate in
the repo's Pages settings. `firefuel.dev` and `firefueldocs.dev` have no DNS records.
