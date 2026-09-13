# 00 — Metadata (Studio "Repository & Tags" card + source details)

**Task ID / folder:** 000-saleor-voucher-usage-lifecycle (practice pre-work task)
**Status:** Draft
**Created:** 2026-09-13

## Studio fields (copy exactly)
| Field | Value |
|---|---|
| Repo name | `saleor/saleor` |
| Repo URL | `https://github.com/saleor/saleor` |
| Primary language | Python |
| Task type (ONE) | Debugging |
| Domain(s) (all that apply) | Backend |
| Interaction mode | Interactive |

## Classification justification
- **Why Debugging:** the starting point is a production symptom (single-use codes rejected with no order behind them, `used` counts drifting from real orders). The root cause is unknown to the model and has to be traced through checkout completion, promo code mutations, and the cleanup task. The work is diagnosis plus a fix and regression tests, not a new feature or a behaviour-preserving refactor.
- **Why Backend only:** everything is server-side: Django domain logic, DB transactions and row locks, a Celery beat task, GraphQL mutations, and a possible migration. No UI work.
- **Why Interactive:** the problem is ambiguous at the start (several independent leak paths, one real limit bypass) and needs design decisions a human should steer: what to persist about held usage, how to release in bulk in the cleanup task, and what to do about checkouts already flagged in production. That naturally takes 5+ meaningful turns (investigate → confirm paths → design → implement → tests → data plan), about 2.5h.

## Source details
- **Researched against commit:** `6e2dc35d0cbc7de85ce3503d5e872e2f672ba70e` on `main` (2026-09-11)
- **Related history:** PR #15849 / #15855 (merged 2024-04-26) introduced `Checkout.is_voucher_usage_increased` to fix a double-completion race
- **Neighbouring open issues (different symptoms, not duplicates):** #18563 (voucher reuse after email change), #18085 (`used` stays 0)
- **Fork/branch for Code Review tasks:** N/A
- **Files the task would touch (5–15+):** see `03-research-notes.md` (~10–15 files)

## Eligibility verification (`bash scripts/verify_repo.sh saleor/saleor`)
```
== saleor/saleor
restricted list: not listed
default branch:  main
HEAD commit:     6e2dc35d0cbc7de85ce3503d5e872e2f672ba70e
last commit:     2026-09-11
code files by extension (vendored dirs excluded):
  .py      4332
  .sh      2
TOTAL code files: 4334
RESULT: PASS (>=200 code files)
```
- [x] Not on restricted list
- [x] ≥200 code files
- [x] Recent commits (maintained)
- [x] Not an invalid category (commerce platform: not an engine, framework, library, or dev tool)
- [x] Enterprise-grade product (used in production by retailers; K8s scale-out deployment model documented in its AGENTS.md)
