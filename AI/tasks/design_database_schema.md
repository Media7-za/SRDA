# 1. Task Metadata

## Task Name
Design Database Schema

## File Path
`/ai/tasks/design_database_schema.md`

## Assigned Agent
- Architect Agent

## Priority
- Critical

## Status
- Not Started

---

# 2. Objective

Refine and finalize the complete MVP database schema using Prisma. This task builds on the existing schema work to ensure all relationships, indexes, and snapshots are correctly implemented.

---

# 3. Business Context

The database schema is the single source of truth for the platform's data. Correct snapshotting of prices and names at the time of order is critical for financial integrity.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/docs/PRD_Core.md`
- `/ai/agents/architect_agent.md`
- `/ai/tasks/01_finalize_database_schema.md` (reference existing work)

---

# 5. Dependencies

- System Architecture defined.

---

# 6. Scope

## In Scope
- Refine existing `schema.prisma`.
- Ensure mandatory fields: `id`, `created_at`, `updated_at`.
- Implement Order Snapshots (`item_name`, `item_price`, etc.).
- Ensure `restaurant_id` scoping for multi-tenancy.
- Define explicit deletion policies (CASCADE vs RESTRICT).

## Out of Scope
- SQL migrations (handled by Backend Agent).
- Data seeding.

---

# 7. Inputs
- Existing `/ai/tasks/01_finalize_database_schema.md`
- Business rules for snapshots.

---

# 8. Required Outputs
- Final Prisma schema specifications.
- ER Diagram (Mermaid).
- Deletion policy table.

---

# 9. Acceptance Criteria
- `order_items` stores immutable snapshots of names and prices.
- All core tables (users, restaurants, menu, orders, payments, delivery) included.
- `restaurant_id` present on all business entities.
- Schema follows normalized relational design principles.

---

# 10. Implementation Rules
- Use UUIDs for PKs.
- `snake_case` for all table/column names via `@@map`.
- No `Json` types for core business data.

---

# 11. API / Data Contracts
- Not applicable.

---

# 12. Edge Cases
- Handling of deleted menu items (soft delete vs snapshot preservation).
- Partial payments or refunds in the ledger.

---

# 13. Testing Requirements
- Prisma validation checks.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- Standard DB security practices.

---

# 16. Performance Requirements
- Index all foreign keys and composite keys for common queries (e.g., order history).

---

# 17. Deliverable Format

**Summary**
Brief explanation of schema refinements.

**Schema Design**
Specification of tables and fields.

**ER Diagram**
Mermaid visualization.

---

# 18. Completion Checklist
- [ ] required context files were read
- [ ] schema follows architecture rules
- [ ] snapshot fields present on `order_items`
- [ ] ER diagram produced

---

# 19. Agent Instruction

Execute this task strictly according to `architect_agent.md`. Ensure that the commerce invariants regarding order snapshots are strictly followed.

---
End of File
