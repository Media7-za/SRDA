# 1. Task Metadata

## Task Name
Create Order Data Model Utilities

## File Path
`/ai/tasks/create_order_model.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the internal repository and TypeScript types for reading and interacting with the `orders`, `order_items`, and `order_status_history` tables via Prisma.

---

# 3. Business Context

The order is the central artifact of the business. It binds together the menu, the customer, the payment, and the delivery driver. Cleanly isolating the database logic for Orders ensures that the business logic layer remains pristine.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/architecture.md` (Commerce Invariants)

---

# 5. Dependencies

- `create_database_models.md`
- Prisma Client generated.

---

# 6. Scope

## In Scope
- Create `OrderRepository` to handle complex Prisma queries.
- Method to fetch a single order by ID with all relations (`items`, `payments`, `status_history`, `delivery`).
- Method to fetch order history for a specific `userId`.
- Method to fetch active orders for a `restaurantId` (Admin feed).
- Define standardized TypeScript interfaces for the "Hydrated Order" return type.

## Out of Scope
- Modifying the database schema.
- Implementing the HTTP routes (handled in API task).

---

# 7. Inputs
- Prisma Schema definitions for `orders`.

---

# 8. Required Outputs
- `src/repositories/OrderRepository.ts`
- `src/types/order.types.ts`

---

# 9. Acceptance Criteria
- `OrderRepository` successfully wraps Prisma logic.
- Fetch methods retrieve snapshot fields correctly.
- Types ensure that frontend-facing responses conform to safe structures (e.g., stripping internal Prisma fields if necessary).

---

# 10. Implementation Rules
- Always `include` the `order_items` when fetching an order so the frontend has the full receipt.
- Enforce that the repository throws a standard NotFoundError if an ID does not exist.

---

# 11. API / Data Contracts
Not applicable (internal repository API).

---

# 12. Edge Cases
- Fetching an order that has no payment records yet (should safely return an empty payments array).

---

# 13. Testing Requirements
- Unit tests mocking Prisma to verify the correct `include` clauses are used.

---

# 14. Observability / Logging
- Log slow queries if Prisma execution exceeds a threshold (optional but recommended).

---

# 15. Security / Permissions
- Internal access only.

---

# 16. Performance Requirements
- Optimize the active orders query, as the restaurant dashboard will hit it frequently. Use indexing effectively.

---

# 17. Deliverable Format
Standard backend implementation.

---

# 18. Completion Checklist
- [ ] types strongly defined
- [ ] repository encapsulates prisma calls

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`.

---
End of File
