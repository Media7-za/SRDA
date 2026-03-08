# 1. Task Metadata

## Task Name
Create Update Cart API

## File Path
`/ai/tasks/create_update_cart_api.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement endpoints to update item quantities or remove items entirely from the cart.

---

# 3. Business Context

Customers often change their minds. Smooth cart editing is essential before proceeding to checkout.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`

---

# 5. Dependencies

- `create_cart_service.md`
- `create_add_to_cart_api.md`

---

# 6. Scope

## In Scope
- Create `PATCH /cart/items/:lineItemId` to update quantity.
- Create `DELETE /cart/items/:lineItemId` to remove an item.
- Create `DELETE /cart` to clear the entire cart.

## Out of Scope
- Updating the options of an *existing* cart item (usually, it's easier to remove and re-add).

---

# 7. Inputs
Patch payload:
```json
{
  "quantity": 3
}
```

---

# 8. Required Outputs
- Updates to `CartController`.

---

# 9. Acceptance Criteria
- Quantity can be updated.
- If quantity is updated to 0, the item is removed from the cart.
- Deleting an item removes it and returns recalculated totals.
- Clearing the cart empties it completely.

---

# 10. Implementation Rules
- The server must always recalculate and return the full cart state after an update.

---

# 11. API / Data Contracts
Standard envelope returning the full Cart object.

---

# 12. Edge Cases
- Updating a line item that doesn't exist in the cart (404).
- Passing negative quantities (should be treated as 0 / remove).

---

# 13. Testing Requirements
- Test updating to 0.
- Test normal update.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- Public route (but identifies user via JWT if present).

---

# 16. Performance Requirements
- Standard.

---

# 17. Deliverable Format
Standard backend outputs.

---

# 18. Completion Checklist
- [ ] quantity 0 = remove
- [ ] negative quantity rejected/handled
- [ ] totals acturately recalculated

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`.

---
End of File
