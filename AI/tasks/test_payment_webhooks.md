# 1. Task Metadata

## Task Name
Test Payment Webhooks

## File Path
`/ai/tasks/test_payment_webhooks.md`

## Assigned Agent
- QA Agent

## Priority
- Critical

## Status
- Not Started

---

# 2. Objective

Verify that standard Stripe webhooks successfully synchronize the local order state, and ensure that malformed or forged webhook signatures are rejected.

---

# 3. Business Context

Webhooks are the bridge between the bank and the kitchen. If this fails, paid orders never get cooked. If it's forged, free food is given away.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/qa.md`

---

# 5. Dependencies

- `create_payment_webhook_handler.md`
- Setup Stripe CLI locally.

---

# 6. Scope

## In Scope
- Create a backend integration test that synthetically bypasses Stripe (by signing a fixture payload using a local test secret) and POSTs to `/webhooks/stripe`.
- Assert that sending an invalid signature returns `400 Bad Request`.
- Assert that sending a valid `payment_intent.succeeded` event successfully updates `orders.status` to `confirmed` and `payment_status` to `paid`.
- Assert that sending the exact same payload twice (idempotency check) returns `200 OK` but does NOT duplicate the ledger entry.

## Out of Scope
- Frontend UI (this is a purely backend test).

---

# 7. Inputs
- Mock Stripe Event payloads.

---

# 8. Required Outputs
- Integration test `stripe-webhook.test.ts`.

---

# 9. Acceptance Criteria
- Bad signatures rejected.
- Good signatures accept string.
- Order syncs.
- Idempotency holds.

---

# 10. Implementation Rules
- Must use `stripe.webhooks.generateTestHeaderString` inside the Jest test to construct a valid signature for the raw payload buffer.

---

# 11. API / Data Contracts
Tests `POST /webhooks/stripe`.

---

# 12. Edge Cases
- Webhook arrives for an `orderId` that does not exist in the database.

---

# 13. Testing Requirements
- Backend integration (Jest/Supertest).

---

# 14. Observability / Logging
- Test output.

---

# 15. Security / Permissions
- Signature validation is the core test.

---

# 16. Performance Requirements
- Test must ensure the route responds `<100ms` (since business logic should ideally be async or fast).

---

# 17. Deliverable Format
Test scripts.

---

# 18. Completion Checklist
- [ ] Forgeries rejected
- [ ] Sync logic verified
- [ ] Idempotency proven

---

# 19. Agent Instruction
You are the QA agent. Treat webhooks as hostile external input. Verify the backend parses raw bodies securely.

---
End of File
