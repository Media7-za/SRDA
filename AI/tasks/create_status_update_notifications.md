# 1. Task Metadata

## Task Name
Create Status Update Notifications

## File Path
`/ai/tasks/create_status_update_notifications.md`

## Assigned Agent
- Backend Agent

## Priority
- Medium

## Status
- Not Started

---

# 2. Objective

Wire the `OrderNotificationService` into the existing API controllers, webhooks, and state machine transitions so notifications fire smoothly during the live order lifecycle.

---

# 3. Business Context

The infrastructure is ready; now it must be triggered at the exact right moment to keep staff and customers informed.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`

---

# 5. Dependencies

- `create_order_notification_service.md`
- `create_order_status_system.md`
- `create_payment_status_sync.md`

---

# 6. Scope

## In Scope
- Inject `OrderNotificationService.notifyNewOrder` into the Stripe Webhook (or `create_payment_status_sync.md` logic) when an order transitions to `confirmed`.
- Inject `notifyCustomerStatusChange` inside `OrderStatusService.advanceStatus()`.
- Inject `notifyDriverAssigned` when dispatching (if driver tracking is active).

## Out of Scope
- Refactoring the core logic of the state machine.

---

# 7. Inputs
None (Code injection task).

---

# 8. Required Outputs
- Updated `OrderStatusService` and `PaymentService`/`OrderService`.

---

# 9. Acceptance Criteria
- Confirming an order immediately fires a push to the restaurant Staff.
- Staff marking an order as `preparing`, `ready_for_pickup`, or `dispatched` fires a push to the specific Customer.
- The notification dispatch logic is separated entirely from the database transaction logic. If the push notification fails or times out, the database status update must STILL SUCCEED.

---

# 10. Implementation Rules
- **CRITICAL INVARIANT:** Push notifications are side-effects. Do not await the push notification promise within the database transaction block. The DB transaction must commit first, then the push should be fired asynchronously.

---

# 11. API / Data Contracts
N/A

---

# 12. Edge Cases
- Notification provider downtime (catch errors to prevent crashing the worker).

---

# 13. Testing Requirements
- Mock the `OrderNotificationService` inside the State Machine tests to verify it gets called exactly once upon a successful transition.

---

# 14. Observability / Logging
- Catch and log FCM/OneSignal errors.

---

# 15. Security / Permissions
- Standard.

---

# 16. Performance Requirements
- Fire and forget approach (e.g., event emitters, or `.catch(console.error)` promises on NodeJS) to keep API responses blazing fast.

---

# 17. Deliverable Format
Standard backend implementation.

---

# 18. Completion Checklist
- [ ] Push decoupled from DB Transaction
- [ ] Customer notified on staff action
- [ ] Staff notified on payment webhook
- [ ] Failing pushes do not fail the API

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`. Focus entirely on the architectural rule: *Side effects must not block core commerce logic*.

---
End of File
