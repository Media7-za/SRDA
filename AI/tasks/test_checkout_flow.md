# 1. Task Metadata

## Task Name
Test Checkout Flow (E2E)

## File Path
`/ai/tasks/test_checkout_flow.md`

## Assigned Agent
- QA Agent

## Priority
- Critical

## Status
- Not Started

---

# 2. Objective

Verify the complete End-to-End (E2E) process of adding items to a cart, selecting fulfillment, initializing the order, and passing the correct payment intent total to the frontend.

---

# 3. Business Context

If the checkout flow breaks, the business makes zero revenue. This is the single most critical pathway in the entire application.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/qa.md` (If existing, or general testing standards)
- `/ai/architecture.md` (Commerce Invariants)

---

# 5. Dependencies

- Frontend and Backend Checkout/Cart integrations must be complete.
- Test Database seeded with at least one active restaurant and one menu item.

---

# 6. Scope

## In Scope
- E2E Web test (e.g., Playwright or Cypress) simulating a customer journey:
  1. Bootstrapping app.
  2. Adding an item to the cart (with 1 option).
  3. Filling out the checkout form (Delivery details).
  4. Asserting the network payload to `/checkout/initiate` is correct.
  5. Asserting the Stripe `<PaymentElement />` renders.
- Verify that attempting to checkout an item that has `is_available=false` in the database results in a graceful UI error.

## Out of Scope
- Actually processing real payments (use Stripe Test Mode cards).

---

# 7. Inputs
- Test environment credentials.
- Test Mode Stripe keys.

---

# 8. Required Outputs
- Cypress/Playwright test suite script (e.g., `checkout.spec.ts`).

---

# 9. Acceptance Criteria
- Test passes consistently without flakiness.
- Test correctly intercepts and mocks Stripe if testing purely locally without internet, or uses Stripe test keys if doing a full E2E run.
- Test asserts the exact amount passed to the payment intent matches the Cart UI total mathematically.

---

# 10. Implementation Rules
- Never use real credit card numbers. Use `.env.test` exclusively.

---

# 11. API / Data Contracts
Intercepts `POST /cart` and `POST /checkout/initiate`.

---

# 12. Edge Cases
- Checking out with a quantity of 0 (UI should prevent, test should assert).

---

# 13. Testing Requirements
- See In Scope.

---

# 14. Observability / Logging
- Output concise test result logs.

---

# 15. Security / Permissions
- Standard.

---

# 16. Performance Requirements
- E2E suites should clean up their database state (e.g., tear down the test user and order) after running.

---

# 17. Deliverable Format
Test scripts.

---

# 18. Completion Checklist
- [ ] Happy path verified
- [ ] Out-of-stock path verified
- [ ] Mathematics asserted

---

# 19. Agent Instruction
You are the QA Agent. Act like a malicious user trying to break the cart math. Ensure the system holds up.

---
End of File
