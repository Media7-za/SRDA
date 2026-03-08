# 1. Task Metadata

## Task Name
Build Order Tracking Screen

## File Path
`/ai/tasks/build_order_tracking_screen.md`

## Assigned Agent
- Frontend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement a live-updating screen that shows the customer the current status of their order, the estimated time of arrival, and (if dispatched) a map/indicator of the driver's location.

---

# 3. Business Context

Customers stare at this screen heavily after paying. Keeping it auto-updating reduces support calls ("Where is my food?") and builds trust through transparency.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/frontend_agent.md`
- `/ai/architecture.md` (State machines)

---

# 5. Dependencies

- `build_checkout_screen.md` (Redirects here on success).
- `create_order_tracking_api.md` (Provides the data).

---

# 6. Scope

## In Scope
- Create `/app/orders/[id]/tracking/page.tsx`.
- Implement a React Query polling mechanism (or WebSocket listener if API uses SSE).
- Build a visual "Timeline" or "Stepper" component matching the architecture's state machine (Pending -> Confirmed -> Preparing -> Ready -> Dispatched -> Delivered).
- Read the current `status` from `GET /orders/:id/tracking` and illuminate the correct step.
- Display a map or simple ETA string if `driverLocation` is provided in the `dispatched` state.

## Out of Scope
- Actually building complex map rendering (MVP can just show a Google Maps static image or a simple text ETA based on the status).

---

# 7. Inputs
- URL Route parameter: `[id]` (OrderId).

---

# 8. Required Outputs
- `OrderTrackingPage` component.
- `OrderTimelineProgress` visual component.

---

# 9. Acceptance Criteria
- Page successfully polls/subscribes to the backend tracking API without hammering it (e.g., 5-10 second interval using `refetchInterval` in React Query).
- Progress bar updates visually when the API status string changes without requiring a manual page refresh.
- Delivered state stops polling immediately.

---

# 10. Implementation Rules
- Always handle the `pending` state cleanly (payment might be finalizing via Webhook in parallel). If it sits in pending for too long, suggest the user contact support.

---

# 11. API / Data Contracts
Consumes `GET /orders/:id/tracking`.

---

# 12. Edge Cases
- Re-opening this page hours later on an order that is already completed. (Should cleanly display "Delivered" and offer a "Reorder" button, with polling disabled).
- Polling fails repeatedly due to network loss (show offline indicator).

---

# 13. Testing Requirements
- Component test for `OrderTimelineProgress` to ensure all states render the correct active steps.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- Route requires authentication (or a secure guest token tied to the order) to prevent users from iterating IDs and stalking drivers.

---

# 16. Performance Requirements
- Utilize `refetchInterval` safely. Stop interval on unmount or on 'delivered' status.

---

# 17. Deliverable Format
Next.js page, React Query hook, UI components.

---

# 18. Completion Checklist
- [ ] Progress stepper visualizes state
- [ ] Polling implemented safely
- [ ] Cleanup on Unmount/Delivered active

---

# 19. Agent Instruction
Execute strictly according to `frontend_agent.md`. State visualization must be dead clear.

---
End of File
