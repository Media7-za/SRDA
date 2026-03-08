# 1. Task Metadata

## Task Name
Test Order Status Flow (E2E State Machine)

## File Path
`/ai/tasks/test_order_status_flow.md`

## Assigned Agent
- QA Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Verify that orders progress through the defined state machine sequentially and that invalid state jumps are rejected by the backend and handled cleanly by the frontend.

---

# 3. Business Context

Kitchen staff rely on accurate order states. If an order skips "Preparing" and goes straight to "Delivered", logging and analytics break.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/qa.md`
- `/ai/architecture.md` (State machine definition)

---

# 5. Dependencies

- `build_orders_dashboard.md`
- `create_order_status_system.md`
- Test Database seeded with a `pending` order.

---

# 6. Scope

## In Scope
- API Integration Test: Sending a `PATCH` to jump from `pending` -> `delivered` directly. Assert it returns `400 Bad Request`.
- UI E2E Test: Log in as `admin`, locate the pending order card, and click the sequence of buttons (Confirm -> Prepare -> Ready -> Dispatch) and assert the UI updates immediately.
- Assertion that the `order_status_history` table contains one row per status change with accurate timestamps.

## Out of Scope
- Webhook tests (handled in a separate task).

---

# 7. Inputs
- Admin JWT.

---

# 8. Required Outputs
- E2E Test script (e.g., `admin-dashboard-state.spec.ts`).
- Backend Integration test (e.g., `order-status.test.ts`).

---

# 9. Acceptance Criteria
- Invalid transitions are strictly blocked.
- Valid transitions succeed.
- UI does not crash or permanently hang on invalid transitions.

---

# 10. Implementation Rules
- Testing must include validating that 'Pay in-store' works for collection but fails for delivery.

---

# 11. API / Data Contracts
Tests `PATCH /orders/:id/status`.

---

# 12. Edge Cases
- Concurrent `PATCH` requests.

---

# 13. Testing Requirements
- E2E framework (Playwright/Cypress) and Backend framework (Jest).

---

# 14. Observability / Logging
- Test runner output.

---

# 15. Security / Permissions
- Test asserting that a `customer` role cannot `PATCH` an order status.

---

# 16. Performance Requirements
- Standard.

---

# 17. Deliverable Format
Automated test scripts.

---

# 18. Completion Checklist
- [ ] Invalid jump blocked
- [ ] Golden path succeeded
- [ ] History table populated
- [ ] RBAC enforcement verified

---

# 19. Agent Instruction
You are the QA Agent. Ensure the UI realistically reflects the backend constraints.

---
End of File
