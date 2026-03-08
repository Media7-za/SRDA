# 1. Task Metadata

## Task Name
Integrate Stripe Payments

## File Path
`/ai/tasks/integrate_stripe_payments.md`

## Assigned Agent
- Backend Agent

## Priority
- Critical

## Status
- Not Started

---

# 2. Objective

Implement the server-side integration with the Stripe SDK to create PaymentIntents immediately after a pending order is generated.

---

# 3. Business Context

Secure payment processing is essential. Generating a PaymentIntent on the backend allows the frontend to securely collect card details without sensitive data ever touching our servers.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/architecture.md` (Commerce Rules)
- `/ai/implementation_decisions.md` (Payment modes)

---

# 5. Dependencies

- `create_checkout_service.md` (Pending order must exist first).
- Stripe Secret Key configured via `setup_environment_config.md`.

---

# 6. Scope

## In Scope
- Install the official `stripe` Node SDK.
- Create `PaymentService` to handle Stripe communication.
- Create POST `/checkout/:orderId/payment-intent`.
- Look up the finalized order total.
- Create a Stripe PaymentIntent with the correct `amount` (in cents), `currency` (ZAR), and attach metadata (`orderId`, `restaurantId`, `userId` if authenticated).
- Initialize a record in the local `payments` ledger table as `pending`.
- Return the `clientSecret` to the frontend.

## Out of Scope
- Actually processing the charge (this is handled directly by Stripe via the frontend Elements SDK).
- Webhook logic (next task).

---

# 7. Inputs
- URL path: `orderId`
- Configuration: Stripe Keys

---

# 8. Required Outputs
- `PaymentService` handling Stripe initialization.
- Updates to `CheckoutController` (or a dedicated `PaymentController`).

---

# 9. Acceptance Criteria
- Stripe PaymentIntent is created correctly in ZAR cents (e.g., R150.00 = 15000).
- Metadata is attached to the PaymentIntent so webhooks can identify the order later.
- A `pending` ledger entry is added to the `payments` database table.
- The `clientSecret` is securely passed back to the frontend.

---

# 10. Implementation Rules
- Idempotency: If a PaymentIntent already exists for this exact order and the total hasn't changed, reuse the existing Intent rather than creating a new one (prevents duplicate charges).
- Multiply all decimal amounts correctly to convert to the integer subunit expected by Stripe.

---

# 11. API / Data Contracts
Response:
```json
{
  "success": true,
  "data": {
    "clientSecret": "pi_123_secret_456"
  },
  "error": null
}
```

---

# 12. Edge Cases
- Order is already marked as `paid`. (Reject request).
- Order doesn't exist.

---

# 13. Testing Requirements
- Unit test ensuring decimals are converted to integers safely (e.g. 15.99 -> 1599).
- Mock the Stripe SDK to verify metadata is passed.

---

# 14. Observability / Logging
- Log initialization of Stripe SDK.

---

# 15. Security / Permissions
- Endpoint must be secured: Customers can only request intents for their *own* orders. Guests can request it using session/cart logic constraints.

---

# 16. Performance Requirements
- Standard.

---

# 17. Deliverable Format
Standard backend implementation.

---

# 18. Completion Checklist
- [ ] Idempotency implemented
- [ ] Currency conversion unit tests
- [ ] Ledger entry created

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`. Do not trust the client to provide the total amount; ALWAYS fetch the subtotal+fees from the DB's `orders` record.

---
End of File
