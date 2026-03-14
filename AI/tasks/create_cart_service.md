# 1. Task Metadata

## Task Name
Create Cart Service & State Management

## File Path
`/ai/tasks/create_cart_service.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the `CartService` to manage the core logic for calculating cart totals, validating items against current menu prices, and handling both guest and authenticated cart state formats.

---

# 3. Business Context

The cart is the gateway to checkout. Ensuring that cart totals are strictly calculated on the server (never trusting the client's math) is a critical commerce invariant.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/docs/PRD_Core.md`

---

# 5. Dependencies

- Menu APIs (for price lookups and availability checks).

---

# 6. Scope

## In Scope
- Define the standard Cart interface/Data Transfer Object (items, selected options, quantities).
- Create logic to recalculate the subtotal by fetching current prices from the DB.
- Create logic to calculate the tax amount based on the subtotal.
- Create logic to validate that items and options in the cart are currently `is_available = true`.
- Implement a strategy for merging a guest cart into an authenticated cart upon login.

## Out of Scope
- Actually processing payment.
- Delivery fee (calculated later during checkout context).

---

# 7. Inputs
Draft Cart Payload shape from client:
```json
{
  "items": [
    {
      "menuItemId": "uuid",
      "quantity": 2,
      "options": ["uuid-option1"]
    }
  ]
}
```

---

# 8. Required Outputs
- `CartService` class.
- Cart Data Models/Types for internal use.
- Unit tests verifying correct math.

---

# 9. Acceptance Criteria
- `CartService` correctly identifies invalid or unavailable items.
- Server correctly recalculates subtotal and tax regardless of what the client claims.
- Graceful error returns if an item price changed or went out of stock while in the cart.

---

# 10. Implementation Rules
- NEVER trust client-supplied totals. Wait, calculate everything from the DB source-of-truth.
- If a database-backed `carts` table was excluded from MVP DB schema, decide here on the temporary persistence strategy (e.g. Redis, or purely validating frontend state sent down the wire).

---

# 11. API / Data Contracts
Not an HTTP endpoint itself, but defines the structure used by the cart APIs.

---

# 12. Edge Cases
- Item is in the cart, but was deleted or made unavailable by the restaurant.
- Option is no longer valid for the item.
- Quantity <= 0.

---

# 13. Testing Requirements
- **Crucial:** Unit tests must aggressively attempt to short-change the cart (e.g., passing in fake prices). `CartService` must ignore them and calculate the true price.

---

# 14. Observability / Logging
- Log instances where client cart state severely mismatches server truth.

---

# 15. Security / Permissions
- Core logic; no direct endpoint exposure.

---

# 16. Performance Requirements
- Price lookups should be batched to avoid N+1 querying when checking a 20-item cart.

---

# 17. Deliverable Format
Standard backend deliverables (Service layer, types, tests).

---

# 18. Completion Checklist
- [ ] server-side pricing enforced
- [ ] missing items handled
- [ ] tests added

---

# 19. Agent Instruction

Execute this task strictly according to `backend_agent.md` and commerce invariants. Mathematical correctness is your top priority.

---
End of File
