# Mercor Code Agent Task Authoring — Project Instructions

We author pre-work coding tasks (repo + opening prompt + 3 rationales) that are later used to evaluate coding agents. We do NOT run or rate models in this phase.

## Always read first
- [PLAYBOOK.md](PLAYBOOK.md): rules, quality bars, workflow, output spec (source of truth, derived from `guides/`)
- [REPO-BANK.md](REPO-BANK.md): verified eligible repos
- [tasks/INDEX.md](tasks/INDEX.md): task log and mix tracker

## Hard rules
- Repo must pass `bash scripts/verify_repo.sh owner/repo` (not in `restricted-repos.txt`, ≥200 code files) and must not be an invalid category (container engine/orchestrator, DB/storage engine, observability pipeline, dev tooling/emulator, UI framework, utility library).
- Enterprise-grade only. Backend-heavy preferred. Favour Debugging / Deployment-DevOps / Code Review when there is a genuine choice.
- Every claim in the prompt and rationales must be verified in the actual code at a recorded commit: real paths, real modules, a gap unsolved on the default branch. Never invent bugs, files, or issue numbers.
- Don't mirror the guide's examples (Formbricks idempotency, Recipe-of-the-Day cache stampede, SSO PR review, ArgoCD stuck, EU upload resets, Steiner tree) or the Gradio placeholder.
- Interactive prompts: short, natural, no spec sheets. Async prompts: self-contained, with acceptance criteria and verification, but not step-by-step.
- Each rationale answer >200 characters, specific and mechanism-level.

## Division of labour
Claude researches, drafts the prompt, and writes full **draft** rationales in plain, natural, specific language. The author rewrites all text in their own words before submitting to Studio.

## Per-task output
Copy `tasks/_TEMPLATE/` → `tasks/NNN-<repo-slug>-<topic>/` and fill `00-metadata`, `01-opening-prompt`, `02-rationale`, `03-research-notes`, `04-qc-and-submission`. Update `tasks/INDEX.md`.

## Environment notes (Windows)
- git over HTTPS needs `git -c http.sslBackend=schannel ...` (the default CA bundle fails).
- Clone repos into `_repos/` (gitignored). No `gh` CLI; the anonymous GitHub API is limited to 60 req/hr, so prefer git and WebFetch for issues.
