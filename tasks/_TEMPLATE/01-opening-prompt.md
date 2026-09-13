# 01 — Opening Prompt

**Mode:** Interactive / Async

## Final prompt (Studio-ready — paste exactly)
```text

```

## High-level task goal / what "done" looks like (for the reviewer; may be implicit in the prompt)
-

## Prompt checks
- [ ] Reads like a real Slack message/ticket a senior engineer would send
- [ ] Anchored in something that exists in the repo (real subsystem/config/symptom)
- [ ] Symptom or goal given; root cause / solution NOT handed over
- [ ] Concrete, testable end state
- [ ] Non-trivial: can't be solved in one turn; needs 5–15+ files
- [ ] Not already solved on the default branch
- [ ] Not mirroring guide examples (Formbricks idempotency, Recipe-of-the-Day cache stampede, SSO PR review, ArgoCD stuck deploy, EU upload resets, Steiner tree)
- [ ] No "test everything" / "examine the whole system" / "make it better"
- **Interactive only:**
  - [ ] Short and natural; no spec-sheet headings, long lists, or code blocks
  - [ ] Difficulty comes from codebase context and realistic ambiguity
  - [ ] Hints at follow-ups (e.g. tests after the fix) without spelling them out
- **Async only:**
  - [ ] Self-contained: context, goal, constraints
  - [ ] Acceptance criteria ("add/update tests that prove: …")
  - [ ] Verification steps (real test/lint/typecheck commands for the changed area)
  - [ ] Deliverables stated if non-code output is expected
  - [ ] Not a step-by-step walkthrough, not exhaustive

## Drafting history (optional)
- v1:
