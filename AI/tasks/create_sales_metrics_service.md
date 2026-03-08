# 1. Task Metadata

## Task Name
Create Sales Metrics Service

## File Path
`/ai/tasks/create_sales_metrics_service.md`

## Assigned Agent
- Backend Agent

## Priority
- Medium

## Status
- Not Started

---

# 2. Objective

Implement the complex database querying logic required to calculate total revenue, total orders, and average order value (AOV) precisely across different time periods.

---

# 3. Business Context

The dashboard relies on this service for its headline figures. Accuracy is non-negotiable, and the service must correctly distinguish between successful payments, refunds, and cancelled orders.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/architecture.md` (Commerce Rules & Snapshots)

---

# 5. Dependencies

- Prisma schema finalized (`orders`, `payments` ledgers).

---

# 6. Scope

## In Scope
- Create `AnalyticsService.getSalesSummary(restaurantId, startDate, endDate)`.
- Query the `orders` table to count total orders. Include only orders that are `confirmed` or later in the lifecycle (exclude `pending` or `cancelled`).
- Sum the `total_amount` from those valid orders for the revenue metric.
- Calculate AOV (Total Revenue / Total valid orders).

## Out of Scope
- Actually generating the API response (handled by `create_restaurant_analytics_api.md`).

---

# 7. Inputs
- `restaurantId` (uuid)
- `startDate` (Date object)
- `endDate` (Date object)

---

# 8. Required Outputs
- `AnalyticsService` class (or similarly named domain service).

---

# 9. Acceptance Criteria
- Excludes `pending` and `cancelled` orders from the revenue count.
- If using the `payments` ledger instead of `orders.total_amount`, ensures only `succeeded` ledgers are summed (minus any `refunded` ledgers).
- Returns 0 for all metrics if no orders exist in the date range (no NaN or divide-by-zero errors).

---

# 10. Implementation Rules
- **CRITICAL INVARIANT:** Decide whether to aggregate from the `orders` snapshot totals or aggregate directly from the `payments` ledger. Summing `orders.total_amount` where `payment_status = 'paid'` is generally faster for MVP dashboards. Stick to the Architect's defined source of truth.

---

# 11. API / Data Contracts
Internal service method signature.

---

# 12. Edge Cases
- Divide by zero when calculating AOV on a slow day (0 orders).
- Orders spanning across timezone boundaries (e.g., an order at 11:59 PM).

---

# 13. Testing Requirements
- Unit tests mocking different database states (mix of pending, paid, cancelled orders) and asserting the correct sums are returned.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- Internal service logic only.

---

# 16. Performance Requirements
- Use Prisma's `aggregate` features (`_sum`, `_count`, `_avg`) rather than using `.findMany()` and summing records in JavaScript memory. This prevents memory exhaustion as order volume grows.

---

# 17. Deliverable Format
Standard backend logic.

---

# 18. Completion Checklist
- [ ] `_sum` and `_count` used instead of in-memory JS maps
- [ ] Divide by zero prevented
- [ ] Pending/Cancelled strictly excluded

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`. Database querying performance is the key aspect here. Do not load thousands of orders into Node.js memory.

---
End of File
