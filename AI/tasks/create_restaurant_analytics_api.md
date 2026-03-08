# 1. Task Metadata

## Task Name
Create Restaurant Analytics API

## File Path
`/ai/tasks/create_restaurant_analytics_api.md`

## Assigned Agent
- Backend Agent

## Priority
- Medium (Post-MVP core flows, but vital for business insights)

## Status
- Not Started

---

# 2. Objective

Implement the REST endpoints that allow restaurant administrators to access aggregated sales, operations, and item-level data to populate the analytics dashboard.

---

# 3. Business Context

Restaurant owners need a high-level view of their business performance (revenue, volume) immediately upon opening the admin dashboard. This API aggregates database records securely and efficiently.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/architecture.md`
- `/ai/tasks/01_finalize_database_schema.md` (To understand how snapshots and ledgers work).

---

# 5. Dependencies

- `create_auth_middleware.md` (RBAC is critical here).
- `create_sales_metrics_service.md` (Provides the calculation logic).
- `create_popular_items_query.md` (Provides the ranking logic).

---

# 6. Scope

## In Scope
- Create `GET /restaurants/:restaurantId/analytics/summary` (revenue, order count, average order value).
- Create `GET /restaurants/:restaurantId/analytics/items` (popular items ranking).
- Accept query parameters for filtering by time ranges (e.g., `?period=today`, `?period=this_week`, `?period=this_month`).

## Out of Scope
- Detailed customer cohort analysis (Growth phase).

---

# 7. Inputs
- Path param: `restaurantId`.
- Query param: `period` (`today`, `week`, `month`, `all_time`).
- JWT Token containing user role & authorization.

---

# 8. Required Outputs
- `AnalyticsController`.
- Registration of the routes in the backend framework.

---

# 9. Acceptance Criteria
- Endpoints return correctly aggregated data using the underlying services.
- Only authorized staff/admins for the specific `restaurantId` can fetch the analytics (Crucial).
- The `period` query parameter correctly filters the exact timestamps (using UTC locally translated to restaurant timezone if required).

---

# 10. Implementation Rules
- Controllers must remain thin. They parse the `period` string into exact `[startDate, endDate]` DateTime objects, authorize the request, and pass those dates to the underlying services.

---

# 11. API / Data Contracts
Success Response Example (`/summary`):
```json
{
  "success": true,
  "data": {
    "totalRevenue": 15000.50,
    "orderCount": 120,
    "averageOrderValue": 125.00
  },
  "error": null
}
```

---

# 12. Edge Cases
- Invalid `period` parameter (default to `today` or return 400).
- Requesting analytics for a restaurant with zero orders (return 0s, not nulls or crashes).

---

# 13. Testing Requirements
- E2E tests verifying RBAC (Staff of Restaurant A cannot see Analytics for Restaurant B).

---

# 14. Observability / Logging
- Log if analytics queries take longer than 1 second to resolve.

---

# 15. Security / Permissions
- Strict RBAC: Must be `admin`, or `staff` explicitly linked to the `restaurantId`.

---

# 16. Performance Requirements
- Analytics queries can be slow. Ensure the controller handles the promise efficiently. For MVP, realtime DB queries are acceptable; later this may require caching (e.g., Redis).

---

# 17. Deliverable Format
Standard backend implementation.

---

# 18. Completion Checklist
- [ ] Cross-tenant data leakage prevented
- [ ] Timezone logic considered
- [ ] Null/Zero data handled correctly

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`. Security is paramount: never leak financial data to unauthorized accounts.

---
End of File
