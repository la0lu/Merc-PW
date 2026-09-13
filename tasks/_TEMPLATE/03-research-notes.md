# 03 — Research Notes (evidence — not submitted)

Everything in the prompt and rationales must trace back to something here.

## Local clone
- Path: `_repos/<repo>` · commit `<sha>`
- How to run tests / lint / typecheck:

## Architecture map
- **Purpose / users:**
- **Stack:** languages · frameworks · DB · cache · queue · deploy
- **Entry points:**
- **Main modules (real paths) and responsibilities:**
- **Data / control flow relevant to the task:**
- **Test layout:**

## The gap (evidence)
- **Source:** issue # / doc / TODO / code reading
- **Where it lives (file:line):**
- **Why it exists:** (design debt, missing guard, legacy path…)
- **Proof it's unsolved on default branch:** (no merged fix, open PRs checked)
- **Reproduction idea:**

## Files the solution would touch (target 5–15+)
| File | Why |
|---|---|

## Difficulty levers present
- [ ] Hidden invariant
- [ ] Concurrency / race / distributed state
- [ ] Cross-layer span
- [ ] Multiple code paths must change together
- [ ] Non-trivial reproduction
- [ ] Backward compatibility / in-flight data
- [ ] Misleading surface fix (reward-hacking bait)

## Expected good solution (author's mental model — keeps rationales honest)
-

## Likely model failure modes
-

## Code Review tasks only
- Fork/branch/PR URL:
- Planted issues (never put these in the prompt):
  1.
