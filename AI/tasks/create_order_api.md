# 1. Task Metadata

## Task Name
Create Order API

## File Path
`/ai/tasks/create_order_api.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the REST endpoints for customers to view their order history and for restaurant staff to view the live queue of active orders.

---

# 3. Business Context

Customers need to see their past receipts for trust and re-ordering. Restaurant staff absolutely require a live feed of what needs to be cooked right now.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`

---

# 5. Dependencies

- `create_order_model.md`
- `create_auth_middleware.md`

---

# 6. Scope

## In Scope
- Create `GET /orders` (Protected). If role is `customer`, return their historical orders. If role is `staff`/`admin`, return active orders for their restaurant.
- Create `GET /orders/:id` (Protected). Return full details of a specific order.

## Out of Scope
- Placing an order (that was handled by `create_checkout_service.md`).
- Changing order status (next task).

---

# 7. Inputs
- JWT Token (for `userId` and `role`).

---

# 8. Required Outputs
- `OrderController`
- `OrderService` (wiring Repository to HTTP logic).
- Express/Fastify Routes targeting `/orders`.

---

# 9. Acceptance Criteria
- Customers can only fetch their own orders (tested by attempting to fetch another user's order ID).
- Response cleanly formats the order snapshot data (items, prices, totals).
- Staff can fetch the active order queue.

---

# 10. Implementation Rules
- Apply strictly layered RBAC. The controller must derive the filter (e.g., `userId` or `restaurantId`) solely from the validated JWT token, never from a client-provided query string for security.

---

# 11. API / Data Contracts
Response (List):
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "status": "pending",
      "totalAmount": 150.0,
      "createdAt": "2023-10-27T..."
    }
  ],
  "error": null
}
```

---

# 12. Edge Cases
- Pagination on a customer with 100+ past orders. Implement basic `?limit` and `?offset` (or cursor).

---

# 13. Testing Requirements
- E2E tests verifying customers cannot view other customers' orders.
- Validating the exact shape of the returned JSON against the contract.

---

# 14. Observability / Logging
- Standard request logging.

---

# 15. Security / Permissions
- `GET /orders` requires JWT.
- `GET /orders/:id` requires JWT AND ownership check (or Staff role).

---

# 16. Performance Requirements
- Use pagination to prevent massive payloads.

---

# 17. Deliverable Format
Standard backend outputs.

---

# 18. Completion Checklist
- [ ] RBAC ownership check enforced
- [ ] Pagination implemented
- [ ] Snapshots returned safely

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`.

---
End of File
