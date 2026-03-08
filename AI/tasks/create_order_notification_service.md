# 1. Task Metadata

## Task Name
Create Order Notification Service

## File Path
`/ai/tasks/create_order_notification_service.md`

## Assigned Agent
- Backend Agent

## Priority
- Medium

## Status
- Not Started

---

# 2. Objective

Define the centralized business logic that decides *who* gets notified about *what*, and formats the messages sent to the `NotificationSender`.

---

# 3. Business Context

Notification noise leads to users disabling alerts. The system needs a dedicated service to construct clear, helpful messages across both Customer and Staff domains.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/architecture.md` (State machines)

---

# 5. Dependencies

- `setup_push_notifications.md` (Notification utility exists).
- `create_order_status_system.md` (State machine implemented).

---

# 6. Scope

## In Scope
- Create `OrderNotificationService`.
- Map system events to specific pushes.
  - Event: `order.created` -> Notify: Restaurant Admin / Staff ("New Order #1234 - R150.00").
  - Event: `order.status_changed` -> Notify: Customer ("Your order is now Preparing").
  - Event: `driver.arrived` -> Notify: Customer ("Your driver is outside").

## Out of Scope
- Actually hooking into the controllers (that is the next task).

---

# 7. Inputs
- Events triggered by the system.
- Order payloads.

---

# 8. Required Outputs
- `OrderNotificationService` class.
- Template definitions for notifications.

---

# 9. Acceptance Criteria
- The service correctly identifies the FCM tokens required (e.g., looking up all `staff` tokens for the affected `restaurantId`).
- The title and body strings are formatted cleanly.
- The `dataPayload` passed contains deep-link capability (e.g., `{"click_action": "order_details", "orderId": "123"}`).

---

# 10. Implementation Rules
- Keep formatting logic separate from sending logic. Ensure the service handles cases where users have no tokens gracefully without throwing an error that bubbles up.

---

# 11. API / Data Contracts
No external API (Internal Service).

---

# 12. Edge Cases
- Missing user/staff tokens.
- Push setting disabled by user in DB (if you designed a preferences table).

---

# 13. Testing Requirements
- Unit test mapping logic (e.g., given status X, generates output string Y).
- Test that querying staff tokens targets only active staff for that specific restaurant.

---

# 14. Observability / Logging
- Log: "Notification generated for Order 123 sent to 2 devices."

---

# 15. Security / Permissions
- Internal system usage only.

---

# 16. Performance Requirements
- Asynchronous execution.

---

# 17. Deliverable Format
Standard backend implementation.

---

# 18. Completion Checklist
- [ ] Staff targeting logic built
- [ ] Deep-link payload included
- [ ] Formatted cleanly

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`.

---
End of File
