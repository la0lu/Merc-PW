# 04 — QC and Submission Log

## Pre-submit checklist (from the guide)
**Codebase & setup**
- [x] Public on GitHub, not on restricted list
- [x] 200+ code files with real complexity (4,332 .py)
- [x] Enterprise-grade, maintained (last commit 2026-09-11)

**Task quality**
- [x] Production-realistic scenario (support escalation about vouchers after card declines / tax outage)
- [x] Concrete goal with success criteria (usage converted or released exactly once; tests with limited vouchers; plan for stuck data)
- [x] Touches ~5–15+ files (≈10–15, see research notes)
- [x] Non-obvious: not one-turn, not already solved (verified at `6e2dc35`, no PR found)
- [x] A senior engineer would plausibly assign it
- [x] Hard enough to surface meaningful model differences (partial fixes, race regression, tautological test trap)
- [x] Clear, testable "done"

**Tags & mode**
- [x] Language (Python), Task Type (Debugging), Domain (Backend), Interaction Mode (Interactive) set
- [x] Task type matches the actual work (symptom → root cause → fix + regression tests)
- [x] Prompt matches mode (short, natural, no spec structure)

**Rationale**
- [ ] All three rewritten in the author's own words, each >200 chars ← **author to do**

## Self-simulated AutoQC (before Studio)
| Dimension | Self-verdict | Notes / fix |
|---|---|---|
| Opening prompt quality (prompt & task design) | Pass | Real symptom, business impact, constraint (multi-pod race), follow-ups implied |
| Mode alignment | Pass | Interactive: 3 short paragraphs, no lists/code, leaves design open |
| Frontier-model difficulty | Pass | 6 paths, transaction/lock reasoning, misleading test, race regression risk |
| Success criteria & deliverables | Pass (watch) | Implicit in prompt: root cause + fix + limited-voucher regression tests + data plan. If AutoQC flags vagueness, add one sentence like "I need usage counts to be exact again" |
| Task type accuracy | Pass | Debugging: symptom given, cause unknown |
| Codebase adequacy | Pass | 4.3k Python files, enterprise commerce platform |
| Codebase understanding / explanation | Pass | Q2 names layers, flows, modules, deploy model |

## Studio AutoQC runs
### Run 1 — YYYY-MM-DD
| Dimension | Result | AutoQC comment | Action (Fix / Dispute + rationale) |
|---|---|---|---|

## Disputes (only when certain AutoQC is wrong)
-

## Submission
- Submitted for review:
- Result:

## Reviewer feedback & revisions
-

## Lessons → playbook updates
- Shared test fixtures that make domain logic a no-op (e.g. a voucher with no limits) are a good source of hidden gaps: check what a fixture actually exercises before trusting an assertion.
