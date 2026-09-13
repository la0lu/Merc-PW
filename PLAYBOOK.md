# Code Agent Task Authoring — Playbook

The single source of truth for how we author pre-work tasks in this workspace.
Distilled from `guides/Mercor task guide.pdf`, `guides/creating-task-mp4-transacript.txt`, and `guides/auto-qc-mp4-transcript.txt`.
When this file and the guide disagree, the guide wins — update this file.

Related files:
- [REPO-BANK.md](REPO-BANK.md) — verified, eligible repos to pick from
- [restricted-repos.txt](restricted-repos.txt) — repos that get auto-rejected
- [scripts/verify_repo.sh](scripts/verify_repo.sh) — eligibility check (restricted list + code-file count + activity)
- [tasks/_TEMPLATE/](tasks/_TEMPLATE/) — copy this for every new task
- [tasks/INDEX.md](tasks/INDEX.md) — running log of tasks and the domain / type mix

---

## Part 1 — What the project is

### 1.1 The two stages
| Stage | What happens | Our role |
|---|---|---|
| **Pre-work (now)** | We author task specs: repo + opening prompt + 3 rationales. | Author only. We do **not** run, compare, or rate models. |
| **Evaluation sprints (later)** | Two coding agents attempt each task; a reviewer compares them, watching for failures like agentic laziness and reward hacking. | Run the task with the models, rate them. |

A task is worth something only if it produces a **signal**: the model must be pushed hard enough to show real behavioural differences.
- Too trivial or already solved in the repo → solved on turn 1 → no signal.
- Too broken or underspecified to be completed at all → no signal.
- **Target zone:** a non-obvious, real problem that takes several meaningful turns (interactive) or a long multi-step autonomous run (async). Success is allowed — the path just has to be demanding.

### 1.2 What changed vs. previous sprints
- **Enterprise-grade software only** (open-source enterprise products, long-horizon projects, or clones of enterprise products).
- **Heavy push towards backend.** Frontend only when clearly enterprise-grade.
- **Greenfield discouraged** unless genuinely ambitious (new service, new library).

### 1.3 The quality bars every task must hit
1. **Commercial realism** — a real production development scenario.
2. **Context** — large codebase, **200+ actual code files** (SVG, MD, TXT, JSON, lockfiles do not count), complex dependencies.
3. **Difficulty** — L5+/staff-level work at a large company. Push harder, not softer.
4. **Scope** — touches roughly **5–15+ files**, not a single-file or tutorial change.
5. **Non-obvious and unsolved** — not solvable in one turn, and not already fixed on the repo's default branch (the URL we submit is the repo root, not a commit).
6. **Testable "done"** — a reviewer can tell whether the task was completed.

---

## Part 2 — Classification (Studio tags)

### 2.1 Interaction mode (pick one)
| | **Interactive / pairing** | **Async / autonomous** |
|---|---|---|
| Sprint behaviour | Human works with the model over turns: feedback, redirection, follow-ups. | Model gets everything up front and runs to the end uninterrupted. |
| Size | Needs **5+ meaningful turns**, about **2.5 hours** of interaction. | Hours of human-equivalent work; a frontier model runs **15+ minutes** on its own. |
| Prompt | **Short, natural, complex but not detailed.** Goal stated clearly, reasonable details left open. Reads like a Slack message or ticket to a colleague. | **Self-contained**: goal, context, constraints, acceptance criteria, verification steps. Not a step-by-step walkthrough and not exhaustive. |
| Most common failure | Over-writing: lists, code blocks, "Definition of Done" sections → trim it. | Under-specifying: "find 3 things, fix them, test everything" → no scope, no done criteria. |

### 2.2 Domain (tag ALL that apply) — target mix
| Domain | Target | Covers |
|---|---|---|
| **Backend** | **45%** | APIs (REST/GraphQL), DB schema & queries, auth, data pipelines, caching, queues, CLIs, systems programming, server config, performance |
| Frontend | 15% | Components, state, styling, routing, forms, browser APIs, frameworks, build tooling, a11y, e2e |
| DevOps/SRE | 15% | CI/CD, Terraform/K8s, incident response, observability tooling |
| MLE/Data | 10% | Eval harnesses, tensor ops, notebooks, statistics, data pipelines |
| Other | 15% | Cross-cutting/specialized — label what kind |

### 2.3 Task type (pick ONE primary) — target mix
| Type | Target | Notes for authoring |
|---|---|---|
| **Debugging** | **18%** | Symptom given, root cause not. The bug must really exist on the default branch. |
| **Deployment / DevOps** | **18%** | CI/CD, containers, infra, deployment config, broken pipelines, upgrade rollouts. |
| **Code Review** | **15%** | Needs a real diff (≈400 lines) with 2–3 genuine issues. We have to prepare that branch/PR on a public fork. |
| Feature Development | 9% | New functionality in an existing codebase. |
| Product Interaction | 9% | Visual/UX fixes, UI polish, a11y, building and interacting with a web app. |
| Refactoring | 6% | Restructure without behaviour change (parity must be provable). |
| Testing | 6% | Test strategy, coverage, harnesses. |
| System Design | 5% | Architecture planning, technical decisions. |
| Requirement Scoping | 3% | Scoping new requirements. |
| Migration | 2% | Dependency/framework/language-version upgrades. |
| Other | 9% | Describe in comments. |

**Rule:** the tag must match the real work. A task that builds a feature is not "Debugging". When there is a genuine choice, favour the big buckets (Debugging, DevOps, Code Review; Backend).

---

## Part 3 — AutoQC and human review

### 3.1 AutoQC
- An automated review of the task on **seven quality dimensions**. The video shows these labels: *Prompt & task design / opening prompt quality*, *mode alignment*, *frontier-model difficulty*, *success criteria & deliverables*, *task type accuracy*, plus checks for *codebase adequacy* and *codebase explanation*.
- It is **advisory**: it doesn't change task status, and a human reviewer still decides. **An all-green AutoQC is not approval.**
- Submit is blocked while AutoQC has unaddressed failures.
- Each category has **Agree / Dispute / Comment**. Dispute (thumbs down + written rationale) **only** when we are certain AutoQC is wrong. The default is to **fix and re-run**.
- Read the passes too — they spell out the criteria.

### 3.2 What the human reviewer scrutinizes most
The **three rationale answers**. They must prove (a) the task is genuinely hard and (b) the author really understands the codebase. The reviewer rejects **generic or LLM-sounding** answers.

> **Workspace policy:** Claude writes full draft rationales and prompts. **The author personally rewrites everything in their own voice before submitting** (the guide flags GenAI-written responses and grammar tools like Grammarly/Quillbot). Drafts live in the task folder; what goes into Studio is the rewritten version.

---

## Part 4 — Studio fields (exactly what gets submitted)

| # | Field | Rules |
|---|---|---|
| 1 | **Repo name** | `owner/repo` |
| 2 | **Repo URL** | Public HTTPS **root** URL, e.g. `https://github.com/go-gitea/gitea`. Not SSH, not a commit, branch, or tree URL. |
| 3 | **Primary language** | The dominant language of the code the task touches |
| 4 | **Task type** | One primary |
| 5 | **Domain(s)** | All that apply (full-stack = Backend + Frontend; add DevOps if deploy is involved) |
| 6 | **Interaction mode** | Interactive or Async |
| 7 | **Opening prompt** | The exact ticket/Slack-style text the model receives in the sprint |
| 8 | **Rationale Q1** — *Why would frontier models struggle with this task?* | **>200 characters.** Name the specific hard property. |
| 9 | **Rationale Q2** — *What does this codebase do?* | **>200 characters.** System, stack, rough size, modules that matter to the task, architecture. |
| 10 | **Rationale Q3** — *What issues or gaps does the codebase have, and how would a developer get started?* | **>200 characters.** Concrete gap + realistic first step (usually a failing test). |

Then: **Run AutoQC → fix → re-run → Submit for Review** (inputs lock → *Awaiting Review*). If Submit does nothing, a required field is empty (look for the error toast).
If it comes back for revision: read Writer Feedback, fix, re-run AutoQC, resubmit.

---

## Part 5 — How to write each piece well

### 5.1 Opening prompt
**Qualities:** realistic · non-trivial · not artificially detailed · mode-matched · concrete goal · uses the project's real vocabulary (modules, services, config keys, commands).

**Interactive template (shape, not text to copy):**
> [Situation/symptom in 1–3 sentences with real, specific signals] → [what I want: the goal] → [where to start or what I suspect, optional] → [1–2 constraints or follow-ups mentioned in passing, e.g. "we'll need concurrency tests after"].

**Async template (shape):**
> Context paragraph (what is broken or needed, why it matters, observed behaviour) → the task (investigate + implement a production-ready fix/feature) → constraints (backward compat, no contract changes, no unrelated refactors) → "Add or update tests that prove:" (3–5 behavioural bullets) → verification ("run the relevant test suite + lint/typecheck for the changed area") → deliverables if non-code output is expected (report, migration plan).

**Do:**
- Anchor the prompt in something that really exists in the repo (a subsystem, a config, a real open issue's symptom).
- Give symptoms, not root causes (debugging).
- Give a testable end state.
- Leave room for the model to discover the tricky part (the invariant, the second code path, the migration edge case).

**Don't:**
- Mirror the guide's examples (Formbricks idempotency, "Recipe of the Day" cache stampede, SSO PR review, ArgoCD stuck, EU upload resets, Steiner tree utility) → rejected as duplicative.
- Say "examine the whole system", "test everything", "make it better".
- Hand over the solution in the prompt.
- Put spec-sheet structure into an interactive prompt.
- Pick a problem already fixed on `main`, or with an open PR that fixes it cleanly and is one click away.

### 5.2 Rationale Q1 — Why is it hard for frontier models?
Name the **mechanism** of difficulty. Strong levers:
- **Hidden invariant** (ordering, idempotency, tenancy isolation, money rounding, timezone/DST).
- **Concurrency / races / distributed state** (queues, retries, locks, transaction boundaries, cache invalidation).
- **Cross-layer span** (the fix crosses ORM ↔ service ↔ API ↔ worker ↔ migration).
- **Multiple code paths** that must all change (v1/v2 API, sync/async task, EE vs CE, plugin hooks).
- **Reproduction is non-trivial** (needs concurrent load, a specific DB, a multi-service setup, a feature flag).
- **Backward compatibility / in-flight data** (mixed-version deploys, existing rows, serialized payloads).
- **Misleading surface** (the obvious fix hides the symptom but breaks another path, which invites reward hacking such as weakening a test).

Formula: *what is subtle* + *where it spans (files/services)* + *why a model will likely take a shortcut or miss it*.

### 5.3 Rationale Q2 — What does the codebase do?
Formula: **what the system is** (product/purpose, who uses it) + **stack** (languages, frameworks, DB, queue, cache) + **rough size** (use our verified count) + **main modules relevant to the task** (real directory/module names) + **how data or control flows through them**.
Not "it's a web app". Show architectural understanding at least one level below the README.

### 5.4 Rationale Q3 — Gaps and how to start
Formula: **the concrete gap** (where it lives, why it exists: design debt, missing guard, legacy path) + **realistic first step** (usually a **failing test** that pins the behaviour) + **the direction of the fix** (e.g. unique constraint + idempotency key inside the transaction).

### 5.5 Pre-submit self-check (from the guide)
Codebase: public & not restricted · 200+ code files · enterprise-grade and maintained.
Task: production-realistic · concrete goal · 5–15+ files · not one-turn / not already solved · senior-engineer-assignable · hard enough for signal · testable done.
Tags: language, one type, domains, mode set · type matches the work · prompt matches mode.
Rationale: all three answered, specific, **in the author's own words**, each >200 chars.
Final gate: AutoQC run and passing (or disputes justified).

---

## Part 6 — Step-by-step workflow (what we do for every task)

### Step 0 — Plan the task mix
Open [tasks/INDEX.md](tasks/INDEX.md). Check the running domain/type counts and bias the next task towards under-filled big buckets (Backend; Debugging / DevOps / Code Review).

### Step 1 — Pick the repo
1. Choose from [REPO-BANK.md](REPO-BANK.md), preferring repos the author actually knows (the author must be able to defend the architecture).
2. Run the eligibility check:
   ```bash
   bash scripts/verify_repo.sh owner/repo
   ```
   It must print: not restricted · ≥200 code files · recent commit.
3. Sanity-check against the invalid categories: container engines/orchestrators, databases/storage engines, observability/telemetry pipelines, developer tooling/emulators, UI frameworks, utility libraries.

### Step 2 — Create the task folder
```bash
cp -r tasks/_TEMPLATE tasks/NNN-<repo-slug>-<short-topic>
# e.g. tasks/001-gitea-actions-runner-race
```
Fill `00-metadata.md` with the repo name, URL, the commit SHA we researched against, and the verification output.

### Step 3 — Research the codebase (evidence first, before any prose)
Clone locally (a shallow clone is enough; add `-c http.sslBackend=schannel` on this Windows machine):
```bash
git -c http.sslBackend=schannel clone --depth 1 https://github.com/owner/repo.git _repos/repo
```
Record everything in `03-research-notes.md`:
- **Architecture map**: entry points, main modules, data stores, async workers, config, test layout, how to run tests.
- **Gap sourcing** (in order of reliability):
  1. Open GitHub issues with `bug` / `performance` / `help wanted` labels and real reproduction steps. Confirm no merged or open PR already fixes them.
  2. Known limitations in docs/ADRs/changelogs ("not supported yet", "known issue").
  3. `TODO` / `FIXME` / `XXX` / `HACK` near critical paths.
  4. Structural gaps found by reading code: missing transaction boundary, non-idempotent handler, N+1 on a hot endpoint, no retry/backoff, missing tenancy filter, CI gaps, Docker/Helm misconfiguration.
- **Real file paths** the task would touch (aim for 5–15+).
- **Why it's still unsolved** on the default branch (links to the issue, last activity).
- **How the test suite runs** (commands), so the prompt's verification steps are real.

### Step 4 — Choose type + mode + domains
Pick what the codebase naturally supports; don't force it. Write the justification in `00-metadata.md`.
- A symptom with a hidden cause → Debugging.
- A deploy/CI/Helm/Docker gap → Deployment/DevOps.
- A risky real change area → Code Review (prepare a public fork branch with a ≈400-line diff containing 2–3 real, subtle issues; record the branch URL).
- Mode: interactive when the task naturally benefits from dialogue and ambiguity; async when it can be fully specified and verified.

### Step 5 — Draft the opening prompt → `01-opening-prompt.md`
Use the template for the mode (5.1). Then run the prompt checks inside the template file.

### Step 6 — Draft the three rationales → `02-rationale.md`
Use formulas 5.2–5.4, drawing only on facts in `03-research-notes.md` (real paths, real module names, real counts). Each answer >200 chars.
**The author rewrites all three in their own words** before pasting into Studio (keep both the draft and the final in the file).

### Step 7 — Self-QC → `04-qc-and-submission.md`
Go through the checklist (5.5) and simulate the 7 AutoQC dimensions. Fix weak spots before touching Studio.

### Step 8 — Studio
Create Task → fill fields from `00`, `01`, `02` (final versions) → Run AutoQC → log each run's results in `04` → fix and re-run → dispute only with a written justification → Submit for Review.

### Step 9 — Track
Update [tasks/INDEX.md](tasks/INDEX.md) (status: Draft → In Studio → Awaiting Review → Approved / Revision). Log any reviewer feedback in `04` and turn recurring lessons into edits to this playbook.

---

## Part 7 — Output spec (task folder contents)

```
tasks/
├── INDEX.md                       # log of all tasks + mix tracker
├── _TEMPLATE/                     # copy, never edit in place for a task
└── NNN-<repo-slug>-<topic>/
    ├── 00-metadata.md             # Studio "Repository & Tags" card + source details + verification output
    ├── 01-opening-prompt.md       # final prompt text (Studio-ready) + prompt checks
    ├── 02-rationale.md            # Q1–Q3: Claude draft → author final (Studio-ready) + char counts
    ├── 03-research-notes.md       # architecture map, gap evidence, file paths, issue links, test commands
    └── 04-qc-and-submission.md    # checklist, AutoQC runs, disputes, reviewer feedback, status
```
Code Review tasks also record the fork/branch/PR URL and a list of the planted issues in `03` (never in the prompt).
