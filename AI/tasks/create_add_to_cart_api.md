# 1. Task Metadata

## Task Name
Create Add to Cart API

## File Path
`/ai/tasks/create_add_to_cart_api.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the API endpoint to add an item to the user's cart (or session cart for guests).

---

# 3. Business Context

Customers need a reliable way to add items to their order, including customized options. Failure here directly impacts conversion.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`

---

# 5. Dependencies

- `create_cart_service.md`

---

# 6. Scope

## In Scope
- Create `POST /cart/items` or `POST /cart` endpoint.
- Accept incoming item (ID, quantity, selected options).
- Use `CartService` to validate the item exists and is available.
- Append to the active cart state.
- Return the recalculated cart total to the client.

## Out of Scope
- Checking out.

---

# 7. Inputs
Example payload:
```json
{
  "menuItemId": "uuid",
  "quantity": 1,
  "options": ["uuid-of-option"]
}
```

---

# 8. Required Outputs
- `CartController`
- Routing for `/cart`

---

# 9. Acceptance Criteria
- Valid items are successfully added to the cart state.
- Invalid items or options are rejected with a clear 400 Bad Request.
- Endpoint supports both authenticated users (via token) and guests (via session token or frontend managed state).

---

# 10. Implementation Rules
- If using a session identifier for guests, ensure it's securely managed to prevent cart hijacking.

---

# 11. API / Data Contracts
Response returns the full, recalculated cart shape:
```json
{
  "success": true,
  "data": {
    "items": [...],
    "subtotal": 150.00
  },
  "error": null
}
```

---

# 12. Edge Cases
- Adding an item that already exists in the cart with the EXACT same options (should ideally bump quantity instead of creating a duplicate line item).

---

# 13. Testing Requirements
- Integration test for adding a valid item.
- Integration test for adding an unavailable item.

---

# 14. Observability / Logging
- None strictly required for MVP, though tracking "add to cart" events is useful for analytics later.

---

# 15. Security / Permissions
- Public route (but identifies user via JWT if present).

---

# 16. Performance Requirements
- Standard response time.

---

# 17. Deliverable Format
Standard backend outputs.

---

# 18. Completion Checklist
- [ ] Quantity bumping handled
- [ ] State returned to client correctly

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`.

---
End of File
