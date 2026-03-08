# 1. Task Metadata

## Task Name
Create Popular Items Query

## File Path
`/ai/tasks/create_popular_items_query.md`

## Assigned Agent
- Backend Agent

## Priority
- Low (Nice-to-have for MVP Analytics)

## Status
- Not Started

---

# 2. Objective

Implement a highly optimized query to determine the best-selling menu items by analyzing the historical `order_items` snapshots across successful orders in a given time period.

---

# 3. Business Context

Restaurant owners need to know what sells best to optimize stock preparation and marketing. This relies entirely on the architecture invariant that order items are snapshotted at checkout.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/architecture.md` (Commerce Invariants)

---

# 5. Dependencies

- `create_database_models.md`
- `order_items` must include the `item_name` snapshot.

---

# 6. Scope

## In Scope
- Create `AnalyticsService.getPopularItems(restaurantId, startDate, endDate, limit = 5)`.
- Group by `order_items.item_name` on orders that are in a `paid` or `completed` state.
- Sum the `quantity` sold for each item.
- Sort descending by quantity.
- Return top N items.

## Out of Scope
- Grouping by `menu_item_options` (too granular for MVP dashboard, stick to main items).

---

# 7. Inputs
- `restaurantId` (uuid)
- `startDate`, `endDate` (Date objects)
- `limit` (integer, default 5)

---

# 8. Required Outputs
- Extension to the `AnalyticsService` class.

---

# 9. Acceptance Criteria
- Query accurately ranks items by volume sold, not revenue generated (unless both are returned).
- Query utilizes the snapshot `item_name` on the `order_items` table, NOT joining against the `menu_items` table (which may have had items deleted or renamed).
- Excludes items from failed or cancelled orders.

---

# 10. Implementation Rules
- Prisma's `groupBy` API is perfectly suited for this. Use it to group by `item_name` and `_sum` the `quantity`.

---

# 11. API / Data Contracts
Internal service method returning an array of:
`{ itemName: string, quantitySold: number, rank: number }`

---

# 12. Edge Cases
- Items that were sold but later deleted from the menu (these MUST still appear in the analytics because we query the `order_items` snapshot).
- Ties in volume sold (handle sorting deterministically, e.g., sort by revenue as tie-breaker or alphabetize).

---

# 13. Testing Requirements
- Unit tests verifying the snapshot querying method.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- Internal service only.

---

# 16. Performance Requirements
- Using `groupBy` directly in the database is mandatory. Grouping thousands of records in Node.js memory will crash the worker.

---

# 17. Deliverable Format
Standard backend logic.

---

# 18. Completion Checklist
- [ ] `groupBy` utilized directly in DB
- [ ] Snapshot fields queried, avoiding joins
- [ ] Limit enforced securely

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md` and the architecture rules. The snapshot architecture was designed specifically to make this query fast and accurate regardless of what happens to the live menu. Use it.

---
End of File
