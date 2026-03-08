# 1. Task Metadata

## Task Name
Create Order Status System

## File Path
`/ai/tasks/create_order_status_system.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the state machine and API endpoints that allow staff and the system to advance an order through its lifecycle (Pending -> Confirmed -> Preparing -> Ready -> Dispatched -> Delivered).

---

# 3. Business Context

The status of an order drives the entire operational flow in the kitchen and sets customer expectations. It must be strictly managed to prevent an order going from "Pending" directly to "Delivered" without payment.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/architecture.md` (State Machines section)

---

# 5. Dependencies

- `create_order_api.md`
- `orders` and `order_status_history` tables.

---

# 6. Scope

## In Scope
- Create `PATCH /orders/:id/status`.
- Implement `OrderStatusService` containing the state machine validation logic.
- Write a new record to `order_status_history` on every successful change.
- Enforce the rule: An order cannot move to `confirmed` unless `payment_status` is `paid` (for Stripe) OR it's a "Pay in-store" collection order.

## Out of Scope
- Webhook endpoints (payments trigger status updates, but webhook handling is a separate task).

---

# 7. Inputs
Patch payload (Staff updating status):
```json
{
  "status": "preparing"
}
```

---

# 8. Required Outputs
- `OrderStatusService.ts`.
- Updates to `OrderController`.

---

# 9. Acceptance Criteria
- Valid transitions (e.g., `confirmed` -> `preparing`) succeed and log to history.
- Invalid logic (e.g., jumping from `pending` -> `delivered`) reverts and returns 400 Bad Request.
- Database transaction used so the `orders.status` update and the `order_status_history` insert either both succeed or both fail.
- Staff RBAC enforced for manual updates.

---

# 10. Implementation Rules
- Wrap the update in a Prisma `$transaction`.
- Expose an internal method `advanceStatus(orderId, newStatus, changedBy)` for use by the Stripe Webhook later.

---

# 11. API / Data Contracts
Standard envelope returning the updated order status.

---

# 12. Edge Cases
- Concurrent requests trying to update the status simultaneously (use optimistic concurrency or rely on strict sequential state validation).
- Refunding a cancelled order (cancellation logic).

---

# 13. Testing Requirements
- Unit tests for the state machine logic (testing all valid and invalid transitions based on the `architecture.md` diagram).

---

# 14. Observability / Logging
- Log every status change.

---

# 15. Security / Permissions
- Internal system logic can trigger updates.
- External API calls to `PATCH /status` require `staff` or `admin`.

---

# 16. Performance Requirements
- Standard DB performance.

---

# 17. Deliverable Format
Standard backend implementation.

---

# 18. Completion Checklist
- [ ] DB transactions used for history
- [ ] State machine valid transitions enforced
- [ ] Webhook helper exposed

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`. The state machine is critical for operational integrity.

---
End of File
