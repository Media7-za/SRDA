# Implementation Decisions & MVP Locks

This document records the locked technical and product decisions for the MVP phase. All AI agents must adhere to these constraints to avoid feature creep, unnecessary abstractions, and architectural debt.

## 1. Fulfillment & Payment Modes

The MVP supports two explicit "Fulfillment + Payment" pathways that dictate the checkout, order state, and payment state rules.

### Allowed Combinations

1. **Delivery + Online Payment (Stripe)**
   - The customer pays via Stripe card checkout.
   - Requires generating a Stripe PaymentIntent and creating a `pending` Order.
   - Stripe Webhook is the only trusted source for transitioning the order to `confirmed` and the payment to `succeeded`.

2. **Collection (Pickup) + Pay In-Store**
   - The customer selects pickup and chooses to pay at the counter.
   - Skips Stripe entirely (No PaymentIntent is created).
   - Order drops directly into the queue as `pending` (or `confirmed` if auto-accept is on), with `payment_status` = `unpaid`.

### Explicitly Disallowed Combinations (MVP)

- **Delivery + Pay In-Store (Cash on Delivery):** Not supported to prevent driver fraud and complicated cash reconciliation logic during Phase 1.

## 2. Managing "Pay In-Store" (Single Payment Ledger)

### The Canonical Table: `payments`
To prevent reconciliation drift and ensure standard reporting audits, we use a single, unified `payments` table for *both* Stripe and Pay In-Store records. We do **not** use `orders` as the sole source of truth for payment status. 

`orders.payment_status` is merely an operational read summary.

### Pay In-Store Execution Block
When a restaurant staff member successfully collects cash or card from a customer standing at the counter for an `unpaid` collection order:

1. **Create Payment Record:** A new row is inserted into the `payments` table with:
   - `provider`: `'in_store'`
   - `method`: `'cash'` or `'card_in_store'`
   - `status`: `'succeeded'`
   - `amount` / `currency`: matches order total
   - `collected_at`: server timestamp
   - `collected_by_user_id`: the `user_id` of the staff member acting on the dashboard. **(Staff Accountability)**
2. **Synchronize Order:** Update `orders.payment_status` to `'paid'`.
3. **Transition State (Optional):** If the order was fully prepared and waiting on payment, mark the order as `completed` / `delivered` (depending on exact business logic definition for collection).

### Stripe vs In-Store Schema Examples

*Stripe Online Payment Record:*
```text
provider = stripe
method = card_online
provider_payment_id = pi_...
status = succeeded
collected_by_user_id = null
```

*In-Store Payment Record:*
```text
provider = in_store
method = cash
provider_payment_id = null
status = succeeded
collected_at = 2026-03-06T15:21:00Z
collected_by_user_id = [staff_user_id]
```

## 3. Scope Cut Log

* **Driver Cash Balancing (Cut from MVP):** By disallowing cash-on-delivery for standard driver routes, MVP avoids building complex cashier drop-off rules.
