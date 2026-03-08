# 1. Task Metadata

## Task Name
Test Realtime Updates (Polling/SSE)

## File Path
`/ai/tasks/test_realtime_updates.md`

## Assigned Agent
- QA Agent

## Priority
- Medium

## Status
- Not Started

---

# 2. Objective

Verify that the Customer Tracking screen updates automatically when an Admin changes an order's status, without requiring a manual page refresh.

---

# 3. Business Context

The main value of a digital system over calling the restaurant is real-time passive updates. If the polling/socket breaks, it defeats the app's purpose.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/qa.md`

---

# 5. Dependencies

- `build_order_tracking_screen.md`
- `build_orders_dashboard.md` (to drive the updates).

---

# 6. Scope

## In Scope
- Dual-actor E2E Test (e.g., using two isolated browser contexts in Playwright).
- Context 1 (Customer): Places an order and stays on the `/tracking` screen. Asserts status is "Pending".
- Context 2 (Admin): Navigates to Admin Orders, finds the order, clicks "Confirm".
- Context 1 (Customer): Waits (max 10s depending on polling interval) and asserts the progress bar visually shifts to "Confirmed".

## Out of Scope
- Load testing 500 simultaneous socket connections (that is for a DevOps task).

---

# 7. Inputs
- Test Accounts (1 Customer, 1 Admin).

---

# 8. Required Outputs
- Multi-context E2E Test Script (`realtime-sync.spec.ts`).

---

# 9. Acceptance Criteria
- Customer UI updates within the defined polling/SSE window after the Admin clicks the button.
- React Query invalidates or refetches cleanly.

---

# 10. Implementation Rules
- Since Playwright can open multiple incognito contexts, use `browser.newContext()` to simulate two entirely separate users.

---

# 11. API / Data Contracts
Observes behavior of `/orders/:id/tracking`.

---

# 12. Edge Cases
- Polling stops returning data (network interruption test).

---

# 13. Testing Requirements
- E2E Testing (Playwright is best suited for multi-context).

---

# 14. Observability / Logging
- Test output.

---

# 15. Security / Permissions
- Verify Context 1 cannot see Context 3's tracking screen.

---

# 16. Performance Requirements
- Test should mock timeouts to 0 or speed up polling specifically for test executions to prevent long wait times in CI pipelines.

---

# 17. Deliverable Format
Test scripts.

---

# 18. Completion Checklist
- [ ] Dual-context simulation successful
- [ ] Customer UI responds to admin action passively

---

# 19. Agent Instruction
You are the QA agent. Verify the "magic" aspect of the app—that the customer's phone updates when the kitchen chef taps a button 10 miles away.

---
End of File
