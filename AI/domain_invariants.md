# Domain Invariants

## Project: Restaurant Ordering & Delivery Platform

This document defines **non-negotiable domain laws** of the system.

These rules must **always remain true** regardless of:

* implementation details
* framework changes
* database schema evolution
* future feature additions
* AI-generated code

If any proposed code, schema, or design violates these invariants, the implementation **must be rejected or redesigned**.

These rules exist to prevent **architectural drift and critical commerce bugs**.

Agents required to enforce this file:

* Architect Agent
* Backend Agent
* QA Agent

---

# 1. Order Immutability Law

Once an order is created, the **commercial details of the order must never change**.

The system must store snapshots of all purchasable elements at checkout.

Required snapshots include:

* item_name
* item_price
* quantity
* selected_options
* option_name
* option_price
* subtotal
* delivery_fee
* tax
* total

Menu updates must **never alter historical orders**.

Example violation:

```
Order references menu_items.price dynamically.
```

Correct implementation:

```
OrderItem stores item_price_snapshot.
```

---

# 2. Server Authority Law

The backend is the **single source of truth for all financial calculations**.

Clients must **never be trusted** for:

* order totals
* delivery fee calculation
* tax calculation
* discount application
* price validation

Clients may send:

* item selections
* delivery address
* modifier selections

But the backend must recompute:

```
subtotal
delivery fee
tax
final total
```

Any mismatch must cause checkout failure.

---

# 3. Cart vs Order Separation Law

Cart and Order represent fundamentally different domain concepts.

Cart:

* mutable
* temporary
* may exist client-side
* may be discarded

Order:

* immutable
* authoritative business record
* must persist permanently

Violations include:

```
cart table reused as order
order updated with changing totals
```

Correct flow:

```
Cart
→ Checkout validation
→ Pending Order
→ Payment
→ Confirmed Order
```

---

# 4. Payment Authority Law

Payment verification must **never rely solely on frontend confirmation**.

Only verified payment provider responses may finalize payment.

Required mechanism:

* Stripe webhook verification
* signature validation

Client responses alone cannot transition orders to confirmed.

Correct flow:

```
PaymentIntent created
Customer completes payment
Stripe webhook confirms payment
Order marked confirmed
```

---

# 5. Order State Machine Law

Orders must follow a **strict lifecycle**.

Valid states:

```
pending
confirmed
preparing
ready_for_pickup
out_for_delivery
delivered
cancelled
```

Allowed transitions:

```
pending → confirmed
confirmed → preparing
preparing → ready_for_pickup
ready_for_pickup → out_for_delivery
out_for_delivery → delivered
pending → cancelled
confirmed → cancelled
```

Invalid transitions include:

```
pending → delivered
delivered → preparing
cancelled → preparing
```

The backend must enforce these transitions.

---

# 6. Payment Coupling Law

Order status and payment status must remain logically consistent.

Example rules:

```
order.confirmed requires payment.succeeded
payment.failed cannot produce order.confirmed
```

Valid combinations:

```
order.pending + payment.pending
order.confirmed + payment.succeeded
```

Invalid combinations:

```
order.confirmed + payment.failed
order.delivered + payment.pending
```

---

# 7. Idempotent Checkout Law

Checkout operations must be idempotent.

Multiple requests with the same idempotency key must **not create duplicate orders or payments**.

Example safe flow:

```
Client sends checkout request with idempotency_key
Backend checks if key exists
If yes → return existing order/payment
If no → create new order/payment
```

This protects against:

* double clicks
* network retries
* mobile reconnections

---

# 8. Restaurant Ownership Law

All commercial entities must reference the restaurant that owns them.

Required `restaurant_id` fields:

* menu_categories
* menu_items
* orders
* promotions
* drivers
* deliveries

Even when the MVP supports only a single restaurant.

This invariant prevents a major schema rewrite when expanding to multi-restaurant SaaS.

---

# 9. Authentication Boundary Law

Sensitive operations must require authentication.

Protected operations include:

* menu management
* order status updates
* restaurant configuration
* driver delivery updates

Public endpoints may include:

* viewing menu
* validating cart
* starting checkout

Authorization must be enforced server-side.

---

# 10. Controller Thinness Law

Controllers must not contain business logic.

Controllers are responsible only for:

* parsing HTTP requests
* invoking services
* returning responses

Controllers must **not**:

* calculate totals
* write database queries
* call payment providers directly

Example violation:

```
Controller calculates order price
```

Correct structure:

```
Controller → Service → Repository
```

---

# 11. Repository Isolation Law

Only repository layers may perform database operations.

Repositories may:

* read records
* write records
* run queries

Services must **not execute SQL or ORM queries directly**.

This ensures:

* testability
* maintainability
* consistent data access patterns

---

# 12. Realtime Integrity Law

Realtime updates must reflect **server-side state changes only**.

Clients must never broadcast authoritative updates.

Allowed realtime sources:

* order status change
* driver location update
* delivery assignment

Clients may subscribe but **not control authoritative events**.

---

# 13. Delivery Fee Snapshot Law

Delivery fee must be determined during checkout and stored on the order.

Example:

```
distance band → fee calculated
fee stored in order.delivery_fee
```

Future delivery pricing changes must not alter historical orders.

---

# 14. Domain Evolution Rule

New features must **not violate existing invariants**.

If a new feature requires breaking an invariant:

1. architecture review must occur
2. invariant must be updated
3. migration strategy must be defined

Agents must not silently bypass invariants.

---

# Enforcement

These invariants must be checked by:

Architect Agent

* during architecture design
* during design review

Backend Agent

* during service implementation
* during schema creation

QA Agent

* during test creation
* during scenario validation

If a violation is detected, the agent must:

1. stop implementation
2. report the invariant violation
3. propose an alternative design

---

# Relationship to Other Documents

This file complements:

```
/ai/context.md
/ai/architecture.md
/ai/implementation_decisions.md
/ai/agent_rules.md
```

Roles:

```
context.md → product overview
architecture.md → system structure
implementation_decisions.md → stack choices
agent_rules.md → engineering behavior
domain_invariants.md → domain laws
```

---

# Final Rule

No code may be accepted that violates these invariants.

They exist to ensure the system remains:

* correct
* auditable
* scalable
* safe for financial transactions

---

End of File
