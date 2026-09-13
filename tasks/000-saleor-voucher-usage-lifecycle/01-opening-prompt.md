# 01 — Opening Prompt

**Mode:** Interactive

## Final prompt (Studio-ready — paste exactly)
```text
Support has been escalating voucher complaints all week. Customers get "voucher not applicable" on single-use codes they never actually redeemed (there's no order with that code anywhere), and on two of our limited campaigns the voucher `used` count doesn't match the number of orders that carry the code. It seems to line up with card declines and the tax app outage we had on Tuesday, but that's just a hunch.

Can you dig into how Saleor tracks voucher usage from the moment a code is applied until the checkout either becomes an order or goes away, and figure out where it goes wrong? Keep in mind we run lots of pods completing checkouts at the same time, so whatever we change can't bring back the double-redemption race that was fixed a while ago.

Once we understand the cause, I'll want regression tests that use vouchers that actually have limits, and a plan for the checkouts that are already stuck in a bad state.
```

## High-level task goal / what "done" looks like
- Root cause explained: voucher usage is consumed early (committed before the order exists) and tracked with the `is_voucher_usage_increased` flag, but release isn't guaranteed on every exit path.
- All paths identified and fixed so held usage is either converted into an order or released exactly once:
  1. declined payment in the legacy flow
  2. payment becoming inactive mid-processing
  3. tax/other failures after the increment in the Transactions flow
  4. promo code removed or replaced while usage is held, including the validation bypass for the new code
  5. expired-checkout cleanup
  6. email change for once-per-customer vouchers
- The #15855 double-completion protection still holds (a concurrent completion test still passes).
- Regression tests use limited / single-use / once-per-customer vouchers and assert exact `used`, `is_active`, and `VoucherCustomer` state per path. The tautological existing assertion is fixed.
- A written plan (or migration) for checkouts already flagged in production.

## Prompt checks
- [x] Reads like a real Slack message/ticket a senior engineer would send
- [x] Anchored in something that exists in the repo (voucher usage limits, single-use codes, card declines on legacy payments, tax app sync webhooks, multi-pod deployment)
- [x] Symptom and goal given; root cause / solution NOT handed over (no mention of the flag, the fail handler, promo code removal, or the cleanup task)
- [x] Concrete, testable end state (exact usage counts, tests with limited vouchers, data plan)
- [x] Non-trivial: six paths across ~10–15 files; can't be solved in one turn
- [x] Not already solved on the default branch (verified at `6e2dc35`)
- [x] Not mirroring guide examples (not the Formbricks submission idempotency, not the cache stampede)
- [x] No "test everything" / "examine the whole system" / "make it better"
- **Interactive only:**
  - [x] Short and natural; no headings, lists, or code blocks
  - [x] Difficulty comes from codebase context and realistic ambiguity
  - [x] Hints at follow-ups (tests with real limits, stuck checkouts) without spelling them out

## Drafting history
- v1 (2026-09-13): initial draft.
