# 1. Task Metadata

## Task Name
Create Payment Status Sync

## File Path
`/ai/tasks/create_payment_status_sync.md`

## Assigned Agent
- Backend Agent

## Priority
- Critical

## Status
- Not Started

---

# 2. Objective

Implement the critical business logic that synchronizes the master `orders.status` (e.g., moving from `pending` to `confirmed`) and `orders.payment_status` when a payment succeeds or when an in-store payment is recorded by staff.

---

# 3. Business Context

The payment ledger (`payments`) tracks the flow of money. The operations queue (`orders.status`) tracks the flow of food. This sync logic is the bridge that ensures the kitchen never cooks a delivery order that hasn't cleared payment.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/architecture.md` (State Machines)

---

# 5. Dependencies

- `create_order_status_system.md`
- `create_payment_webhook_handler.md`

---

# 6. Scope

## In Scope
- Create an internal method (e.g., `OrderService.markOrderPaid(orderId)`).
- This method updates `orders.payment_status = 'paid'`.
- If `orders.status` is `pending`, it advances it to `confirmed`.
- It inserts a record into `order_status_history` noting the change was system-triggered.
- Implement an API endpoint `POST /orders/:id/pay-in-store` (protected: staff) allowing cashiers to record manual payment for collection orders, which triggers this same flow.

## Out of Scope
- Stripe logic (already handled upstream in webhooks).

---

# 7. Inputs
- Internal trigger from webhook.
- HTTP trigger from Staff UI (Pay In-Store).

---

# 8. Required Outputs
- Synchronized logic in `OrderService` or `PaymentService`.
- Staff endpoint for manual collection override.

---

# 9. Acceptance Criteria
- When Stripe webhook succeeds, the order automatically moves to the Kitchen screen (`confirmed`).
- Staff can manually mark collection orders as paid, pushing them to `confirmed`.
- Synchronous DB transactions prevent partial updates.

---

# 10. Implementation Rules
- Validate that "Pay In-Store" is ONLY allowed if the `orders.order_type` is `collection`. Delivery orders must NEVER be "pay in store".

---

# 11. API / Data Contracts
Staff Endpoint:
```json
{
  "success": true,
  "data": { "status": "confirmed" },
  "error": null
}
```

---

# 12. Edge Cases
- Two webhooks fire simultaneously (idempotency checking using the DB transaction).
- Staff tries to "Pay In-Store" an order that just finalized via Stripe.

---

# 13. Testing Requirements
- Unit test the specific rule: Delivery orders reject "in-store" payment attempts.
- Integration test for atomicity of the DB transaction.

---

# 14. Observability / Logging
- Log event: "Order X master status synced to paid via Provider Y".

---

# 15. Security / Permissions
- Overriding Payment via the API requires `admin` or specific `cashier`/`staff` roles.

---

# 16. Performance Requirements
- Standard DB transaction limits apply.

---

# 17. Deliverable Format
Standard backend implementation.

---

# 18. Completion Checklist
- [ ] Collection vs Delivery rule enforced
- [ ] Master order status advanced automatically
- [ ] DB Transaction wraps the sync

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md` and the invariant lists in `architecture.md`.

---
End of File
