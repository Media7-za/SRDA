# 1. Task Metadata

## Task Name
Build Orders Dashboard (Restaurant Admin)

## File Path
`/ai/tasks/build_orders_dashboard.md`

## Assigned Agent
- Frontend Agent

## Priority
- Critical

## Status
- Not Started

---

# 2. Objective

Implement the live kitchen operations interface where staff view incoming orders, update their statuses, and manage the dispatch pipeline.

---

# 3. Business Context

This is the heartbeat of the restaurant. High visibility, loud visual cues for new orders, and rapid one-click status updates are crucial for kitchen efficiency.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/frontend_agent.md`
- `/ai/architecture.md` (State machines)

---

# 5. Dependencies

- `create_order_api.md` (Provides the active order queue).
- `create_order_status_system.md` (Handles the status PATCH logic).
- `setup_auth_middleware.md` (Admin/staff token is required).

---

# 6. Scope

## In Scope
- Create `/app/admin/orders/page.tsx`.
- Implement a Kanban-style board or a structured list grouped by `status` (e.g., Pending -> Confirmed -> Preparing -> Ready -> Dispatched).
- Connect React Query to `GET /orders` (fetching active queue).
- Setup polling (`refetchInterval`) or SSE to automatically refresh the queue.
- Render `AdminOrderCard` components displaying Order ID, Time elapsed, Items (with options), Total, and Fulfillment Type (Collection vs Delivery).
- Add action buttons on the card to advance the status via `PATCH /orders/:id/status`.
- Add a "Pay In-Store" button exclusively for `collection` orders stuck in `pending`.

## Out of Scope
- Detailed historical order analytics (handled by Analytics UI).

---

# 7. Inputs
- API responses from `GET /orders`.
- Staff interaction (clicks).

---

# 8. Required Outputs
- `AdminOrdersDashboard` component.
- `AdminOrderCard` component.
- Corresponding React Query hooks (`useActiveOrders`, `useUpdateOrderStatus`).

---

# 9. Acceptance Criteria
- Dashboard updates automatically without manual refresh.
- Staff can move an order from Pending -> Confirmed -> Preparing -> Ready -> Dispatched.
- State machines logic is respected (UI should disable invalid jump buttons).
- UI visually highlights orders that have been waiting too long (e.g., red background after 30 mins).

---

# 10. Implementation Rules
- Always use optimistic UI updates when clicking a status button. If the `PATCH` fails, roll back the UI state and show a toast notification.

---

# 11. API / Data Contracts
Consumes `GET /orders` and mutations on `PATCH /orders/:id/status`.

---

# 12. Edge Cases
- Network drops while kitchen is busy. Show a clear 'Offline' warning banner.
- Cancelling an order.

---

# 13. Testing Requirements
- Component testing for the layout grouping logic.
- Integration test for optimistic updates on status change.

---

# 14. Observability / Logging
- None strictly required on frontend.

---

# 15. Security / Permissions
- Route is protected by an Admin layout guard (checks JWT role).

---

# 16. Performance Requirements
- Polling interval set intelligently (e.g., 10 seconds) to avoid hammering the server, until WebSocket/SSE is established.

---

# 17. Deliverable Format
Next.js page, components, and hooks.

---

# 18. Completion Checklist
- [ ] Grouping by status
- [ ] Optimistic updates
- [ ] Offline indicator
- [ ] Pay In-store action restricted to Collection

---

# 19. Agent Instruction
Execute strictly according to `frontend_agent.md`. The UI must feel completely real-time. Fast visual feedback is non-negotiable for staff in a noisy kitchen.

---
End of File
