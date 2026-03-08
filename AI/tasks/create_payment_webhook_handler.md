# 1. Task Metadata

## Task Name
Create Payment Webhook Handler

## File Path
`/ai/tasks/create_payment_webhook_handler.md`

## Assigned Agent
- Backend Agent

## Priority
- Critical

## Status
- Not Started

---

# 2. Objective

Implement a secure webhook endpoint to receive asynchronous push notifications from Stripe regarding payment successes or failures.

---

# 3. Business Context

Relying on the frontend browser to tell the server "payment succeeded!" is a severe security flaw. Webhooks are the ONLY source of truth for payment status. If webhooks fail, orders vanish into the void.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/architecture.md` (Commerce Invariants)

---

# 5. Dependencies

- `integrate_stripe_payments.md` (to know the metadata structure).
- `setup_environment_config.md` (for Stripe Webhook Secret).

---

# 6. Scope

## In Scope
- Create POST `/webhooks/stripe`.
- Read raw request body to explicitly verify the Stripe cryptographic signature using `stripe.webhooks.constructEvent()`.
- Process `payment_intent.succeeded` event.
- Process `payment_intent.payment_failed` event.
- Extract `orderId` from the PaymentIntent metadata.
- Update the `payments` ledger table (`succeeded` or `failed`).
- Respond with 200 OK immediately so Stripe doesn't retry infinitely.

## Out of Scope
- Actually advancing the master order status (that's handled in the Sync task, though you will trigger it from here).

---

# 7. Inputs
- Raw HTTP Request Body (Buffer)
- `Stripe-Signature` Header

---

# 8. Required Outputs
- Special middleware for the webhook route (must NOT run through standard express JSON parsing; requires raw body).
- `WebhookController`
- Routing configuration.

---

# 9. Acceptance Criteria
- Webhook signature verification successfully accepts valid Stripe requests and rejects tampered/unauthorized requests with a 400 status.
- The `payments` ledger record is updated based on the event outcome.
- Webhook endpoints respond within 2 seconds.

---

# 10. Implementation Rules
- You MUST disable the standard `express.json()` middleware ONLY for the `/webhooks/stripe` route, replacing it with `express.raw({type: 'application/json'})`. `stripe.webhooks.constructEvent()` will fail if the body is already parsed into a JS object.
- Idempotency: Webhooks can arrive multiple times or out of order. Ensure you only mark a payment successful once.

---

# 11. API / Data Contracts
Response MUST be empty `HTTP 200`.

---

# 12. Edge Cases
- Webhook arrives but `orderId` is missing from metadata (log error permanently, requires manual review).
- PaymentIntent claims success but amount doesn't match the DB order total (log critical alert).

---

# 13. Testing Requirements
- Describe how to test locally using the Stripe CLI (`stripe listen --forward-to localhost:3000/webhooks/stripe`).

---

# 14. Observability / Logging
- **MANDATORY:** Log every single incoming webhook ID and event type so missing payments can be debugged.

---

# 15. Security / Permissions
- The crypto signature check IS the permission.

---

# 16. Performance Requirements
- Delegate the business logic (syncing order status) asynchronously if possible, so the `200 OK` is returned to Stripe instantly.

---

# 17. Deliverable Format
Standard backend outputs.

---

# 18. Completion Checklist
- [ ] Raw body parser used exclusively here
- [ ] Cryptographic signature verified
- [ ] Ledger idempotently updated

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`. Webhooks are the highest-risk integration point in commerce. Do not cut corners.

---
End of File
