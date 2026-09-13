# Repo Bank — Verified Eligible Repositories

**Verified on 2026-09-13** by shallow-cloning every repo and counting real code files (`.py .ts .tsx .js .go .java .rb .php .cs .rs .vue …`), with `node_modules / vendor / third_party / dist / build` excluded. Every repo below:
- is public on GitHub,
- is **not** on [restricted-repos.txt](restricted-repos.txt),
- has **well over 200 code files**,
- had commits in Aug–Sep 2026 (actively maintained),
- is an enterprise product or enterprise-grade platform (not a framework, utility library, DB engine, container orchestrator, or observability pipeline).

Re-verify before use: `bash scripts/verify_repo.sh owner/repo` (counts drift, and the restricted list may change).

**How to read the "task seams" column:** these are *areas where real, hard enterprise problems tend to live* in that codebase. They are where to start hunting (issues, TODOs, code reading), **not** confirmed bugs. Every task must be grounded in something verified on the default branch during Step 3 of the [PLAYBOOK](PLAYBOOK.md).

**Tiers**
- **Tier A** — backend-heavy enterprise systems with rich concurrency, data-integrity, multi-tenancy, or deploy surface. Best fit for the project's push (Backend 45%; Debugging / DevOps / Code Review).
- **Tier B** — strong enterprise products; full-stack or narrower backend surface.
- **Tier C** — eligible, but with a category or "enterprise-ness" risk a reviewer could question. Use only with a strong justification in rationale Q2.

---

## Tier A — Backend-heavy enterprise systems

| Repo | Lang (code files) | What it is | Key modules (verified top-level) | Task seams to investigate |
|---|---|---|---|---|
| [apache/fineract](https://github.com/apache/fineract) | Java (6,822) | Core banking platform for microfinance/lending (loans, savings, accounting) | `fineract-accounting`, `fineract-cob` (close-of-business batch), `fineract-command-*`, `fineract-charge`, `fineract-branch`, Avro event schemas | COB batch idempotency and partial-failure recovery, accrual/interest rounding, repayment schedule regeneration, external event ordering, Liquibase migration safety |
| [killbill/killbill](https://github.com/killbill/killbill) | Java (1,726) | Subscription billing and payments platform | `account`, `subscription`, `entitlement`, `invoice`, `payment`, `overdue`, `usage`, `catalog`, `tenant`, `jaxrs` | Invoice generation with mid-cycle plan changes, usage billing boundaries, payment retry state machine, tenant isolation, bus/notification queue timing |
| [juspay/hyperswitch](https://github.com/juspay/hyperswitch) | Rust (2,117 .rs + Cypress JS) | Open-source payments switch/orchestrator | `crates/` (router, connectors, storage_impl, redis_interface, diesel_models), `migrations`, `v2_migrations`, `loadtest`, `monitoring` | Connector retry and idempotency, Redis↔Postgres (KV/drainer) consistency, v1→v2 API parity, webhook deduplication, `docker`/Helm deploy config |
| [getlago/lago-api](https://github.com/getlago/lago-api) | Ruby (6,244) | Usage-based billing API (metering → invoicing) | `app/services`, `app/jobs` (Sidekiq), `app/graphql`, `db`, `spec` | Event ingestion dedup, aggregation correctness at period boundaries, invoice-job concurrency and locking, timezone/billing-anchor edge cases, N+1 in GraphQL resolvers |
| [saleor/saleor](https://github.com/saleor/saleor) | Python (4,332) | Headless GraphQL e-commerce platform (Django) | `saleor/checkout`, `order`, `payment`, `warehouse`, `webhook`, `plugins`, `graphql` | Stock allocation races at checkout completion, payment/transaction state consistency, sync-webhook timeouts and retries, multi-channel pricing, DB query performance |
| [go-gitea/gitea](https://github.com/go-gitea/gitea) | Go (3,114) | Self-hosted Git forge (repos, PRs, issues, Actions CI, packages) | `models`, `modules`, `routers`, `services`, `cmd`, `modelmigration`, `web_src` | Actions job scheduling/runner concurrency, queue backends, DB-agnostic migrations (SQLite/MySQL/PG/MSSQL), package-registry protocol edge cases, permission checks across API vs web routes |
| [mattermost/mattermost](https://github.com/mattermost/mattermost) | Go + TS (8,176) | Enterprise team messaging platform | `server` (app, store/sqlstore, API4, jobs, plugin), `webapp`, `e2e-tests` | HA cluster event propagation, store-layer caching and invalidation, job server scheduling, plugin RPC boundaries, DB migration performance on large tables |
| [keycloak/keycloak](https://github.com/keycloak/keycloak) | Java (9,480) | Identity and access management (OIDC/SAML SSO) | `services`, `model`, `federation`, `saml-core`, `authz`, `quarkus`, `operator`, `scim`, `testsuite` | Session/token lifecycle in a clustered cache, LDAP federation sync, authz policy evaluation, operator/K8s deployment config, SCIM provisioning semantics |
| [zitadel/zitadel](https://github.com/zitadel/zitadel) | Go (4,281) | Cloud-native IAM with event sourcing | `internal` (eventstore, command, query, projections), `cmd`, `backend`, `proto`, `apps`, `console` | Projection lag and read-your-writes consistency, eventstore concurrency, multi-instance tenancy, gRPC↔REST gateway parity, deploy/Helm |
| [goauthentik/authentik](https://github.com/goauthentik/authentik) | Python + TS + Go (4,844) | Identity provider (SSO, flows, outposts) | `authentik` (Django core: flows, providers, sources, outposts), `internal` (Go outpost/proxy), `web`, `blueprints` | Flow executor state across stages, outpost↔core sync, LDAP/RADIUS provider performance, blueprint apply idempotency, worker task retries |
| [hashicorp/vault](https://github.com/hashicorp/vault) | Go (4,759) | Secrets management | `vault` (core, token store, expiration manager), `builtin` (secret engines, auth methods), `physical` (storage backends), `audit`, `sdk` | Lease expiration/revocation under load, Raft storage edge cases, audit device failure modes, plugin lifecycle. *(terraform is restricted; vault is not. Keep the task on Vault's own code.)* |
| [temporalio/temporal](https://github.com/temporalio/temporal) | Go (2,949) | Durable workflow execution service | `service` (frontend, history, matching, worker), `common` (persistence, namespace), `schema`, `chasm` | History shard ownership handoff, task queue matching latency, persistence-layer retries, schema upgrade tooling. *(Arguably an "orchestrator": workflow, not container. See Tier C note.)* |
| [thingsboard/thingsboard](https://github.com/thingsboard/thingsboard) | Java (6,540) | IoT platform (device management, rule engine, telemetry dashboards) | `application`, `dao`, `rule-engine`, `transport` (MQTT/CoAP/HTTP), `msa` (microservices), `edqs`, `ui-ngx` | Rule-engine message ordering and retries across queue partitions, transport session handling, time-series DAO performance, microservice deploy config |
| [dhis2/dhis2-core](https://github.com/dhis2/dhis2-core) | Java (6,556) | Health information system used by national ministries | `dhis-2` (services, analytics, tracker, web API), `jenkinsfiles` | Analytics table generation performance, tracker import validation and dedup, sharing/ACL checks at query level, CI pipeline (`jenkinsfiles`) |
| [frappe/erpnext](https://github.com/frappe/erpnext) | Python (3,757) | Full ERP (accounting, stock, manufacturing, HR) | `erpnext/accounts`, `stock`, `manufacturing`, `selling`, `buying`, `controllers` | Stock ledger reposting and valuation (FIFO/moving average) under backdated entries, GL entry consistency, concurrency on submit/cancel, report performance |
| [odoo/odoo](https://github.com/odoo/odoo) | Python + JS (14,578) | ERP/business-app suite | `odoo` (ORM, http, service), `addons/*` (account, stock, sale, mrp, website) | ORM recompute/cache invalidation, multi-company record rules, stock reservation concurrency, cron/queue job overlap. Very large, so scope tightly. |
| [DependencyTrack/dependency-track](https://github.com/DependencyTrack/dependency-track) | Java (1,762) | Software supply-chain / SBOM risk analysis platform | `apiserver`, `vuln-analysis`, `vuln-data-source`, `notification`, `migration`, `secret-management`, `proto` | BOM ingest idempotency, vuln-analysis event pipeline ordering, notification dedup, migration safety |
| [DefectDojo/django-DefectDojo](https://github.com/DefectDojo/django-DefectDojo) | Python (2,467) | Application security vulnerability management | `dojo` (models, importers, tools/parsers, API v2, jira integration), `helm`, `docker`, `unittests` | Reimport dedup/hash-code algorithms, bulk importer performance, JIRA sync consistency, Helm/Docker deploy, Celery task retries |
| [netbox-community/netbox](https://github.com/netbox-community/netbox) | Python (1,336) | Network source-of-truth (DCIM/IPAM) | `netbox` (dcim, ipam, circuits, extras, core, netbox/api, graphql) | Bulk-edit transaction semantics, IP/prefix utilisation query performance, custom-field filtering, change logging and webhooks, GraphQL N+1 |
| [bitwarden/server](https://github.com/bitwarden/server) | C# (5,509) | Password manager backend (API, Identity, Admin, Events) | `src` (Api, Identity, Core, Infrastructure.Dapper/EntityFramework, Events), `bitwarden_license`, `util` (migrators) | Dual data access (Dapper vs EF) parity, org/collection access control, event pipeline, DB migrator for MSSQL/PG/MySQL/SQLite |

## Tier B — Strong enterprise products (full-stack or narrower backend)

| Repo | Lang (code files) | What it is | Key modules | Task seams to investigate |
|---|---|---|---|---|
| [twentyhq/twenty](https://github.com/twentyhq/twenty) | TypeScript (26,607) | Open-source CRM (Salesforce alternative) | `packages/twenty-server` (NestJS, workspace metadata, GraphQL), `twenty-front` | Per-workspace schema migrations driven by metadata, GraphQL resolver performance, background job queues, workspace tenancy |
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | TypeScript (22,362) | Workflow automation platform | `packages/cli` (server, queue mode), `core` (execution engine), `workflow`, `nodes-base`, `frontend/editor-ui` | Queue-mode worker/main coordination, execution data pruning, binary data storage, webhook dedup, partial execution |
| [calcom/cal.com](https://github.com/calcom/cal.com) | TypeScript (5,064) | Scheduling infrastructure | `apps/web`, `apps/api`, `packages` (trpc, prisma, features, app-store) | Availability calculation across timezones/DST, double-booking races, calendar sync idempotency, API v1/v2 parity |
| [medusajs/medusa](https://github.com/medusajs/medusa) | TypeScript (11,903) | Commerce platform (modular) | `packages/core`, `packages/modules/*` (order, cart, payment, inventory), workflows SDK | Workflow compensation/rollback correctness, inventory reservation concurrency, module link consistency |
| [makeplane/plane](https://github.com/makeplane/plane) | TS + Python (3,942) | Project management (Jira alternative) | `apps/api` (Django), `apps/web`, `apps/live`, `packages`, `deployments` | Real-time collaboration sync, bulk issue operations, permission layers, self-host deploy scripts |
| [discourse/discourse](https://github.com/discourse/discourse) | Ruby + JS (15,286) | Community/forum platform | `app`, `lib`, `plugins`, `frontend`, `db`, `spec` | Sidekiq job idempotency, post-processing pipeline, plugin API compatibility, DB migration safety at scale |
| [opf/openproject](https://github.com/opf/openproject) | Ruby + TS (13,418) | Enterprise project management | `app`, `modules/*`, `lib`, `frontend` | Work package scheduling (relations, dates), permission queries, background jobs, packaging/Docker |
| [zammad/zammad](https://github.com/zammad/zammad) | Ruby + TS (9,066) | Helpdesk / customer support | `app` (models, jobs, GraphQL), `lib`, `app/frontend` (Vue) | Ticket escalation/SLA calculation, email channel parsing, search index sync, scheduler jobs |
| [chatwoot/chatwoot](https://github.com/chatwoot/chatwoot) | Ruby + Vue (4,962) | Omnichannel customer engagement | `app` (channels, services, jobs), `enterprise`, `deployment`, `swagger` | Inbound webhook dedup per channel, conversation assignment races, realtime ActionCable events, deploy configs |
| [RocketChat/Rocket.Chat](https://github.com/RocketChat/Rocket.Chat) | TypeScript (9,112) | Team chat with federation | `apps/meteor`, `ee`, `packages` (core-services, models), microservices | Microservice mode vs monolith parity, federation, presence at scale, license-gated EE code paths |
| [novuhq/novu](https://github.com/novuhq/novu) | TypeScript (8,648) | Notification infrastructure | `apps/api`, `apps/worker`, `libs` (dal, application-generic), `enterprise` | Digest/delay job correctness, provider fallback and retries, idempotent trigger handling, queue throughput |
| [triggerdotdev/trigger.dev](https://github.com/triggerdotdev/trigger.dev) | TypeScript (4,212) | Background jobs / durable task platform | `apps/webapp`, `internal-packages` (run-engine, database), `packages`, `hosting` | Run-engine state transitions, checkpoint/restore, concurrency-key limits, self-hosting config |
| [directus/directus](https://github.com/directus/directus) | TypeScript (3,911) | Data platform / headless CMS over any SQL DB | `api` (services, database helpers per vendor), `app`, `sdk` | Cross-vendor SQL generation, permission filtering in nested queries, schema snapshot/apply, caching |
| [apache/superset](https://github.com/apache/superset) | Python + TS (6,792) | BI / data exploration platform | `superset` (db_engine_specs, security, charts, async queries), `superset-frontend`, `helm`, `superset-websocket` | Async query result caching, row-level security, db_engine_spec dialect quirks, Helm deploy, Celery workers. *(apache/airflow and druid are restricted; superset is not.)* |
| [openedx/edx-platform](https://github.com/openedx/edx-platform) | Python (5,403) | Online learning platform (LMS + Studio) | `lms`, `cms`, `openedx/core`, `xmodule`, `common` | Grading/persistent grades recompute, course publish/modulestore, Celery task routing |
| [nextcloud/server](https://github.com/nextcloud/server) | PHP (8,632) | Enterprise file sync and collaboration | `lib/private` (Files, DB, Share20), `apps/*` (dav, files_sharing, encryption), `core` | File locking and cache consistency, share permission propagation, WebDAV edge cases, background jobs |
| [mautic/mautic](https://github.com/mautic/mautic) | PHP (4,843) | Marketing automation | `app/bundles/*` (Campaign, Lead, Email) | Campaign event scheduling at scale, segment rebuild performance, email queue retries |
| [invoiceninja/invoiceninja](https://github.com/invoiceninja/invoiceninja) | PHP (4,577) | Invoicing and payments | `app` (Services, Jobs, PaymentDrivers), `database`, `tests` | Payment gateway webhook dedup, recurring invoice scheduling, multi-currency rounding |
| [grokability/snipe-it](https://github.com/grokability/snipe-it) | PHP (8,544) | IT asset management | `app` (Http, Models, Importer), `database`, `tests` | CSV importer correctness, checkout/checkin state, LDAP sync, API permissions |
| [bagisto/bagisto](https://github.com/bagisto/bagisto) | PHP (3,042) | Laravel e-commerce | `packages/Webkul/*` (Checkout, Sales, Inventory) | Inventory reservation across sources, cart price rules, order state machine |
| [mastodon/mastodon](https://github.com/mastodon/mastodon) | Ruby (4,224) | Federated social network server | `app` (services, workers, lib/activitypub), `streaming`, `chart` | ActivityPub delivery retries and dedup, Sidekiq queue design, Helm chart |
| [spree/spree](https://github.com/spree/spree) | Ruby + TS (5,095) | Commerce platform | `spree` (core, api, dashboard), `packages` | Checkout state machine, stock movements, promotions |
| [solidusio/solidus](https://github.com/solidusio/solidus) | Ruby (2,273) | Commerce platform (Spree fork) | `core`, `api`, `backend`, `admin`, `promotions` | Promotion engine migration (legacy_promotions → promotions), order recalculation |
| [outline/outline](https://github.com/outline/outline) | TypeScript (2,518) | Team knowledge base | `server` (commands, queues, collaboration), `app`, `shared`, `plugins` | Collaborative editing persistence (Y.js), queue processors, permission policies |
| [documenso/documenso](https://github.com/documenso/documenso) | TypeScript (2,110) | Document e-signing | `apps/remix`, `packages` (lib, prisma, signing, trpc) | Signing workflow state consistency, PDF sealing, webhook delivery |
| [openmrs/openmrs-core](https://github.com/openmrs/openmrs-core) | Java (1,378) | Medical record system | `api` (services, Hibernate), `web`, `liquibase` | Hibernate session/transaction boundaries, Liquibase migrations, concept/obs query performance |
| [apache/ofbiz-framework](https://github.com/apache/ofbiz-framework) | Java (1,370) | ERP framework and applications | `framework` (entity engine, service engine), `applications` | Entity engine transaction handling, service engine async jobs, security permissions |
| [nopSolutions/nopCommerce](https://github.com/nopSolutions/nopCommerce) | C# (4,096) | ASP.NET Core e-commerce | `src/Libraries` (Nop.Core, Nop.Data, Nop.Services), `src/Presentation`, `src/Plugins` | Caching layer invalidation, plugin loading, scheduled tasks in multi-instance deployments |

## Tier C — Eligible but with category/enterprise risk (justify carefully or avoid)

| Repo | Code files | Risk |
|---|---|---|
| [appsmithorg/appsmith](https://github.com/appsmithorg/appsmith) | 8,884 (TS + Java) | Low-code app builder; a reviewer may read it as "developer tooling". It is a deployed enterprise product with a Java/Spring server, so it's defensible for backend tasks. |
| [Unleash/unleash](https://github.com/Unleash/unleash) | 6,165 (TS) | Feature-flag platform, close to "developer tooling". Keep tasks on enterprise concerns (RBAC, change requests, multi-env). |
| [temporalio/temporal](https://github.com/temporalio/temporal) | 2,949 (Go) | "Orchestrator" wording overlaps the invalid category, though it orchestrates workflows, not containers. |
| [immich-app/immich](https://github.com/immich-app/immich) | 1,604 (TS) | Consumer self-hosted photo app; weaker "enterprise-grade" argument. |

---

## Explicitly excluded (and why)
- **gradio-app/gradio** — used in the video walkthrough purely as a placeholder; it is a UI framework (invalid category), and mirroring the video is a duplication risk.
- **formbricks/formbricks** — the guide's own async example; a task there risks being flagged as duplicative.
- **Kubernetes, Podman, CockroachDB, TiKV, OpenTelemetry Collector, Flutter, NLog, Spring Session, Grafana/Loki/Jaeger-type projects** — invalid categories.
- **aws/aws-cli, GCP k8s-config-connector, Netflix Lemur** — named in the guide as examples not to use.
- Everything in [restricted-repos.txt](restricted-repos.txt) (111 repos, e.g. django, fastapi, flask, airflow, terraform, prometheus, redis, valkey, laravel/framework, three.js, tokio, axum).

## Adding a repo to the bank
1. `bash scripts/verify_repo.sh owner/repo` → must PASS.
2. Confirm it is an enterprise product or platform, not a library, framework, engine, or dev tool.
3. Add a row with the verified count, real top-level modules, and seams.
