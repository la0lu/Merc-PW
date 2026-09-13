# 02 — Rationales

> Workflow: Claude writes the **Draft**; the author rewrites it in their own words as **Final** (that is what goes into Studio).
> Each Final answer must be **>200 characters**, specific, and reference real mechanisms, modules, and paths from `03-research-notes.md`.

---

## Q1 — Why do you think this is a task that frontier models would struggle with?

### Draft (Claude)
The bug isn't in one place. It's a broken invariant spread across several code paths. To stop two pods from redeeming the same limited voucher at once, Saleor consumes the voucher usage early, in its own committed transaction, before the order exists, and marks the checkout with `is_voucher_usage_increased`. From then on the usage has to end up either in an order or released exactly once, and nothing enforces that.

A declined card in the legacy flow calls the fail handler without the voucher (`_process_payment`). When the payment goes inactive mid-processing, the handler gets the voucher but not the code, so the flag is cleared and nothing is given back. A `TaxDataError` in the Transactions flow rolls back the order but not the usage. Removing a promo code, the expired-checkout Celery task, and an email change all ignore the flag. Worse, when the flag is still set, `get_voucher_for_checkout` skips the active/usage-limit check, so a code swapped in later is never counted at all.

A model will likely patch the first path it finds and stop. It may also point at the existing "usage not incremented after failed payment" test as proof, without noticing the fixture voucher has no limit, so the assertion can't fail. The obvious "just release in every except block" fix double-releases, and moving the increment back into the order transaction brings back the race from #15855. Getting it right needs reasoning about transaction boundaries, commit-on-error blocks, row lock order, and bulk deletes in a Celery task, across roughly 10–15 files.

### Final (author's words — Studio)

Characters: 

---

## Q2 — What does this codebase do?

### Draft (Claude)
Saleor is a headless, GraphQL-only e-commerce platform written in Python/Django (about 4,300 Python files). Storefronts talk to it through a Graphene GraphQL API, and payments and taxes are delegated to apps over sync webhooks. It runs on PostgreSQL with read replicas, uses Celery with Redis/Valkey for background work, and is deployed as many identical pods, so every operation is expected to run concurrently with itself.

The code is layered. GraphQL mutations in `saleor/graphql` (the biggest part, ~116k lines) only validate input and orchestrate, and the business logic sits in domain packages like `checkout`, `order`, `payment`, `discount`, `warehouse` and `webhook`.

The modules that matter here:
- `checkout/complete_checkout.py` turns a checkout into an order. It has two flows: the legacy Payment flow (pre-payment, payment and post-payment steps in separate commit-on-error transactions so the gateway call doesn't hold row locks) and the Transactions flow (`create_order_from_checkout`, also used by `orderCreateFromCheckout` and the automatic completion task).
- `checkout/utils.py` handles adding and removing vouchers and deleting checkouts.
- `checkout/tasks.py` has the `delete_expired_checkouts` beat task.
- `discount/utils/voucher.py` increases and releases usage: the `used` counter, deactivating single-use codes, and `VoucherCustomer` rows for once-per-customer vouchers.

### Final (author's words — Studio)

Characters: 

---

## Q3 — What issues or gaps does the codebase have, and how would a developer get started on solving them?

### Draft (Claude)
The gap is that "voucher usage held by a checkout" has no owner. The boolean `is_voucher_usage_increased` says usage was taken, but not for which code or which customer email. Each exit path handles release on its own, and several don't. A card decline leaves usage held. An inactive payment clears the flag without decrementing, so the next attempt counts twice. Removing or swapping a code, or the cleanup task deleting an abandoned checkout, loses the usage for good, which is why single-use codes show as used with no order. The swapped-in code also skips limit validation. The test suite hides all of this because the shared `voucher` fixture has no usage limit, so `increase_voucher_usage` does nothing in those tests.

A developer would start by writing failing tests with a voucher that has `usage_limit=1` and `single_use=True`: mock `process_payment` to raise `PaymentError` and assert `used` is back to 0 and the code is active again, then do the same for a `TaxDataError` in the Transactions flow, for `checkoutRemovePromoCode` after a failed completion, and for `delete_expired_checkouts`. From there, the fix is to store which code and email the usage was taken for, route every failure through one idempotent release that reads that stored data, release in bulk inside the cleanup delete transaction, and re-validate a newly added code. A concurrent completion test should keep the #15855 race fixed, and a small data migration should handle checkouts that are already flagged.

### Final (author's words — Studio)

Characters: 
