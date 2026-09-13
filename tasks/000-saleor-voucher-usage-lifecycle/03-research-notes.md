# 03 — Research Notes (evidence — not submitted)

Everything in the prompt and rationales must trace back to something here.

## Local clone
- Path: `_repos/saleor` · commit `6e2dc35d0cbc7de85ce3503d5e872e2f672ba70e` (main, 2026-09-11)
- Verification: 4,332 `.py` files, not restricted, active (see `00-metadata.md`)
- How to run tests (from Saleor's `AGENTS.md`): `pytest --reuse-db <path>`; needs Python 3.12, Postgres, and Redis/Valkey (Docker compose in dev). Not run locally yet: the host has Python 3.11 and Docker only.
- Relevant test files:
  - `saleor/checkout/tests/test_checkout_complete.py`
  - `saleor/graphql/checkout/tests/mutations/test_checkout_complete_with_payment.py`
  - `saleor/checkout/tests/test_tasks.py`

## Architecture map
- **Purpose / users:** headless, GraphQL-only commerce platform. Storefronts and apps drive checkout through the GraphQL API; merchants manage catalog, orders, discounts, and warehouses from the Dashboard. Payments and taxes are delegated to apps via sync webhooks.
- **Stack:** Python 3.12 · Django ORM · Graphene GraphQL (`saleor/graphql`, ~116k LOC) · PostgreSQL (with read replicas) · Celery workers + Redis/Valkey · deployed as many identical K8s pods (AGENTS.md: "assume every operation runs concurrently with itself").
- **Domain layering:** GraphQL mutations do validation/orchestration; business logic lives in domain packages (`checkout`, `order`, `payment`, `discount`, `warehouse`, `webhook`). Signals are banned; side effects are called explicitly.
- **Main modules for this task:**
  - `saleor/checkout/complete_checkout.py` (~2,050 lines): converts a checkout into an order. Two flows:
    - **Legacy Payment flow:** `complete_checkout_with_payment` → `complete_checkout_pre_payment_part` → `_process_payment` → `complete_checkout_post_payment_part`. Three separate `transaction_with_commit_on_errors` blocks, so payment runs outside a DB lock.
    - **Transactions flow:** `complete_checkout_with_transaction` → `create_order_from_checkout` (also used by the `orderCreateFromCheckout` mutation and `automatic_checkout_completion_task`).
  - `saleor/checkout/utils.py`: add/remove voucher on checkout, `get_voucher_for_checkout`, `delete_checkouts`.
  - `saleor/checkout/tasks.py`: `delete_expired_checkouts` (Celery beat cleanup), `automatic_checkout_completion_task`.
  - `saleor/discount/utils/voucher.py`: `increase_voucher_usage` / `release_voucher_code_usage` (`VoucherCode.used`, `is_active` for single-use, `VoucherCustomer` rows for once-per-customer).
  - GraphQL entry points: `checkout_complete.py`, `order_create_from_checkout.py`, `checkout_add_promo_code.py`, `checkout_remove_promo_code.py`, `checkout_email_update.py`.
  - `saleor/payment/gateways/stripe/webhooks.py` also calls `complete_checkout`.
- **Size of the checkout domain alone:** 196 non-test `.py` files mention checkout paths; `checkout/` is 145 files / ~13.7k LOC; `discount/` is ~9k LOC.

## Key mechanism: "voucher usage held by a checkout"
Introduced by PR **#15849 / #15855** (merged 2024-04-26, "Fix race concurrency condition for completing checkout with the voucher that has a usage limit").
- `Checkout.is_voucher_usage_increased` (`checkout/models.py:303`).
- `_increase_checkout_voucher_usage` (`complete_checkout.py:138-153`): if the flag is already True, return; otherwise increase usage (limit counter, once-per-customer row, deactivate single-use code) and set the flag True. This is committed early so a concurrent completion can't double count.
- `_release_checkout_voucher_usage` (`complete_checkout.py:156-177`): sets the flag False; releases the code's usage **only if `voucher_code` is passed** (`if voucher_code:`).
- `get_voucher_for_checkout` (`utils.py:541-570`): **when the flag is True, it skips `active_in_channel` validation** (dates, usage limit), on the assumption that the usage already belongs to this checkout.

**Implicit invariant:** once usage is increased for checkout C, it must end in exactly one of: (a) converted into an order, or (b) released exactly once. And the flag must describe the *currently attached* code/customer. Nothing enforces this; each path handles it ad hoc.

## The gap (evidence) — invariant broken on several independent paths
| # | Path | Evidence | Effect |
|---|---|---|---|
| 1 | **Legacy flow, payment declined** | `_process_payment` receives `voucher` and `voucher_code` params but on `PaymentError` calls `_complete_checkout_fail_handler(checkout_info, manager)` **without them** (`complete_checkout.py:1084`). Usage was already committed in the pre-payment block. | Usage stays held with flag True after an ordinary card decline. |
| 2 | **Legacy flow, payment became inactive mid-processing** | Fail handler gets `voucher=order_data.get("voucher")` but **no `voucher_code`** (`complete_checkout.py:1909-1913`). The release helper flips the flag to False but skips the decrement. | Usage **leaks permanently**; the next retry increments again → **double count**. |
| 3 | **Transactions flow, failure after the increment** | Usage increment is committed in its own atomic block (`:1593-1601`); order creation is a second block. Only `InsufficientStock` / `GiftCardNotApplicable` trigger the fail handler (`:1669-1684`). `TaxDataError` (raised at `:1652`), `ValidationError` (no lines) and unexpected errors don't. | Tax-app outage → order rolled back, usage held, checkout survives with flag True. |
| 4 | **Promo code removed/replaced after usage held** | `remove_voucher_from_checkout` (`utils.py:846`) clears `voucher_code` but neither resets the flag nor releases usage; `add_voucher_to_checkout` (`utils.py:754`) doesn't look at the flag. | Old code's usage leaks (single-use code stays deactivated). New code: at completion, flag True → `get_voucher_for_checkout` skips active/usage-limit validation and `_increase_checkout_voucher_usage` returns early → **new code's usage is never counted, so its limit can be bypassed**. |
| 5 | **Abandoned checkout cleanup** | `delete_expired_checkouts` (`tasks.py:41`) → `delete_checkouts` (`utils.py:148`) bulk-deletes rows with no voucher handling. | Every checkout that still held usage leaks it permanently. |
| 6 | **Email changed after usage held** (once-per-customer vouchers) | `VoucherCustomer` row is created for the email at increment time; release uses `get_customer_email_for_voucher_usage(checkout_info)` at release time; `checkoutEmailUpdate` doesn't touch the flag. | Release targets the wrong email: an orphaned usage row for the old email; the new email is never recorded. Neighbour of open issue **#18563** (voucher reuse after email change), which is a different, user-level report. |

**Why tests don't catch it:** `test_checkout_complete_does_not_delete_checkout_after_unsuccessful_payment` (`test_checkout_complete_with_payment.py:3067`) asserts `code.used == expected_voucher_usage_count` after a failed payment (`:3118`). But the `voucher` fixture (`discount/tests/fixtures/voucher.py:10-23`) has **no `usage_limit`, no `single_use`, no `apply_once_per_customer`**, so `increase_voucher_usage` is a no-op and the assertion passes trivially. `test_release_checkout_voucher_usage_no_voucher_code` even pins the "flag False, no release" behaviour of path #2 as expected.

**Proof it's unsolved on main:** all references to `is_voucher_usage_increased` are listed above (grep, commit `6e2dc35`); no release in remove/cleanup/email paths. GitHub search (2026-09-13): no open or merged PR addressing it; related open issues #18563 (email change) and #18085 (`used` stays 0, most likely because `used` only increments when `usage_limit` is set) are different symptoms.

**Reproduction idea (for the author's confidence; not yet executed):** fixture voucher with `usage_limit=1` / `single_use=True`; mock `PluginsManager.process_payment` to raise `PaymentError`; call `checkoutComplete`; assert `code.used == 0` and `code.is_active is True` → fails today. Then `checkoutRemovePromoCode` + delete checkout → still held.

## Files the solution would touch (target 5–15+)
| File | Why |
|---|---|
| `saleor/checkout/complete_checkout.py` | Pass voucher + code to fail handler in `_process_payment` and the inactive-payment branch; release on all failures after the increment in `create_order_from_checkout`; make the release helper resolve the code itself instead of relying on callers |
| `saleor/checkout/utils.py` | Release held usage (or block the change) in `remove_voucher_from_checkout` / `add_voucher_to_checkout`; `get_voucher_for_checkout` must not skip validation for a code that isn't the one usage was increased for; `delete_checkouts` release |
| `saleor/checkout/tasks.py` | Bulk-safe release in `delete_expired_checkouts` without N+1 per row or long locks |
| `saleor/checkout/models.py` + migration | Probably record *which* code/email usage was increased for (the boolean can't express it); backfill/compat for existing flagged rows |
| `saleor/discount/utils/voucher.py` | Bulk release helper; idempotent release |
| `saleor/graphql/checkout/mutations/checkout_remove_promo_code.py`, `checkout_add_promo_code.py`, `checkout_email_update.py` | Call the domain-level release/guard |
| `saleor/checkout/tests/test_checkout_complete.py`, `.../test_checkout_complete_with_payment.py`, `.../test_checkout_complete_with_transactions.py`, `checkout/tests/test_tasks.py`, promo-code mutation tests, `discount/tests/fixtures/voucher.py` | Regression tests with *limited* vouchers; fix the tautological assertion |

## Difficulty levers present
- [x] Hidden invariant (usage held ↔ flag ↔ attached code/email; release exactly once)
- [x] Concurrency / race: the flag exists because of a race (#15855); fixes must keep the double-completion protection, lock ordering (checkout row vs voucher code row) and commit-on-errors semantics
- [x] Cross-layer span (GraphQL mutations → domain → Celery cleanup → model/migration)
- [x] Multiple code paths must change together (legacy payment, transactions, automatic completion task, orderCreateFromCheckout, Stripe webhook completion, promo code add/remove, email update, cleanup)
- [x] Non-trivial reproduction (needs a *limited* voucher, failure injection in a specific phase, `transaction=True` DB tests for races)
- [x] Backward compatibility / in-flight data (existing checkouts with flag True in prod; can't know which code they hold without new data)
- [x] Misleading surface fix: patching only `_process_payment` or pointing at the passing tautological test looks done; blanket "release in every except" breaks the race protection and double-releases

## Expected good solution (author's mental model)
- Make release a domain-level, idempotent operation that knows what it holds: store the held code (and customer email) on the checkout, or derive it reliably, and release by that, not by whatever is currently attached.
- Every failure path after the increment releases through one place (fail handler gets voucher info from the checkout, not from callers).
- Removing or replacing a code while usage is held releases the old usage first, inside a short transaction with the checkout locked; the new code gets full validation.
- Expired-checkout cleanup releases held usage in bulk (aggregate decrements per code, reactivate single-use codes, delete customer rows) in the same transaction as the delete.
- Email change while usage is held moves the once-per-customer row, or releases and re-acquires it.
- Migration/backfill: for existing flagged rows, map `voucher_code` → held code; document ambiguity.
- Tests use limited / single-use / once-per-customer vouchers and assert exact `used`, `is_active`, and `VoucherCustomer` state for each path, including a `transaction=True` race test that the original #15855 protection still holds.

## Likely model failure modes
- Fixes only the first path found (`_process_payment`) and declares victory.
- Cites the existing "voucher usage count was not incremented" test as proof, not noticing the fixture has no limit.
- Removes the flag or moves the increment back into the order transaction, reintroducing the #15855 race.
- Releases in a generic `except Exception` → double release when a later path also releases (`used` clamps at 0 and hides it).
- Ignores the Celery cleanup task, or releases per row in a loop (N+1 on 2,000-row batches, long locks).
- Misses that `get_voucher_for_checkout` skipping validation is a limit bypass, not just a leak.
- No migration/compat thinking for checkouts already flagged in production.
