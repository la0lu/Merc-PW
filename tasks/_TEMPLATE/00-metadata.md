# 00 — Metadata (Studio "Repository & Tags" card + source details)

**Task ID / folder:** NNN-<repo-slug>-<topic>
**Status:** Draft | In Studio | Awaiting Review | Revision | Approved
**Created:** YYYY-MM-DD

## Studio fields (copy exactly)
| Field | Value |
|---|---|
| Repo name | `owner/repo` |
| Repo URL | `https://github.com/owner/repo` ← root HTTPS URL only (no .git, SSH, branch, commit) |
| Primary language | |
| Task type (ONE) | |
| Domain(s) (all that apply) | |
| Interaction mode | Interactive / Async |

## Classification justification
- **Why this task type:** (the actual work is X, so the type is Y, not Z)
- **Why these domains:**
- **Why this interaction mode:** (interactive: ambiguity, 5+ turns, ~2.5h / async: fully specifiable, 15+ min autonomous run)

## Source details
- **Researched against commit:** `<sha>` on `<default branch>` (date)
- **Related issue(s)/PR(s)/docs:** links (confirmed still unresolved on default branch)
- **Fork/branch for Code Review tasks:** URL (or N/A)
- **Files the task would touch (5–15+):** see `03-research-notes.md`

## Eligibility verification (paste `bash scripts/verify_repo.sh owner/repo` output)
```
```
- [ ] Not on restricted list
- [ ] ≥200 code files
- [ ] Recent commits (maintained)
- [ ] Not an invalid category (container engine/orchestrator, DB/storage engine, observability pipeline, dev tooling/emulator, UI framework, utility library)
- [ ] Enterprise-grade product
