# 1. Task Metadata

## Task Name
Build Promotions & Analytics UI

## File Path
`/ai/tasks/build_promotions_ui.md`

## Assigned Agent
- Frontend Agent

## Priority
- Low (Post MVP)

## Status
- Not Started

---

# 2. Objective

Implement a read-only analytics dashboard for viewing sales metrics and (if implemented in backend) the UI to configure discounts/promotions.

---

# 3. Business Context

Restaurant owners check this page to judge business health. It must synthesize complex backend data into clear, simple charts and metrics.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/frontend_agent.md`

---

# 5. Dependencies

- `create_restaurant_analytics_api.md` (Provides the data).

---

# 6. Scope

## In Scope
- Create `/app/admin/analytics/page.tsx`.
- Connect to `GET /restaurants/:id/analytics/summary`.
- Connect to `GET /restaurants/:id/analytics/items`.
- Implement a Date Range Picker to let owners filter the `period`.
- Render Headline KPI cards (Total Revenue, Orders, AOV).
- Render a Leaderboard list for "Top Selling Items".

## Out of Scope
- Actually building complex discount code systems (Unless the backend scope changed). The UI only renders whatever promotion logic was finalized by the Architect.

---

# 7. Inputs
- Date Picker selections.

---

# 8. Required Outputs
- `AnalyticsDashboard` component.
- `KPICard` components.
- Charting libraries (e.g., Recharts if graph is needed, otherwise pure CSS bar charts).

---

# 9. Acceptance Criteria
- Changing the date updates the metrics immediately via React Query refetching.
- Revenue is formatted cleanly as currency.
- Empty states (e.g., zero sales today) render encouragingly, not as JavaScript errors.

---

# 10. Implementation Rules
- Wait until data is loaded to render charts; show skeletons initially.

---

# 11. API / Data Contracts
Consumes the Analytics API response shapes.

---

# 12. Edge Cases
- Invalid date range selections.

---

# 13. Testing Requirements
- Component testing verifying standard metric formats.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- Admin only guard.

---

# 16. Performance Requirements
- Standard.

---

# 17. Deliverable Format
Next.js page and UI components.

---

# 18. Completion Checklist
- [ ] Date picker active
- [ ] KPIs rendered
- [ ] Leaderboard active

---

# 19. Agent Instruction
Execute strictly according to `frontend_agent.md`. Make it look beautiful and executive-level.

---
End of File
