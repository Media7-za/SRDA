# 1. Task Metadata

## Task Name
Create Order Tracking API

## File Path
`/ai/tasks/create_order_tracking_api.md`

## Assigned Agent
- Backend Agent

## Priority
- Medium

## Status
- Not Started

---

# 2. Objective

Provide the customer frontend with the ability to poll or subscribe to real-time updates regarding their active order's status and the delivery driver's location.

---

# 3. Business Context

"Where is my food?" is the highest friction point in food delivery. Real-time, transparent tracking dramatically reduces support calls and improves customer satisfaction.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`

---

# 5. Dependencies

- `create_order_status_system.md`
- Optional: Driver location tables if driver app scope is active.

---

# 6. Scope

## In Scope
- Create `GET /orders/:id/tracking`.
- Return current state, estimated time of arrival (mocked or calculated based on status), and latest `driver_location` if fulfillment is delivery and status is `dispatched`.
- Optional: Implement Server-Sent Events (SSE) or WebSockets at `/orders/:id/live` for push updates (if dictated by PRD for MVP; otherwise rely on HTTP polling).

## Out of Scope
- Actually processing the GPS coordinates from a driver's mobile device (handled by Driver API task).

---

# 7. Inputs
- URL Path: `orderId`.

---

# 8. Required Outputs
- `OrderTrackingService.ts`.
- Updates to `OrderController`.

---

# 9. Acceptance Criteria
- Returns the latest order status and ETA.
- If delivery, returns driver lat/lng (if available).
- Route is protected, ensuring customers can only track their own orders.

---

# 10. Implementation Rules
- If implementing SSE, ensure memory leaks do not occur with open connections.
- If polling, ensure the database query is highly optimized (e.g., fetching only the `status` string rather than joining all order items over and over).

---

# 11. API / Data Contracts
Response:
```json
{
  "success": true,
  "data": {
    "status": "out_for_delivery",
    "updatedAt": "2023-10-27...",
    "driverLocation": { "lat": -29.0, "lng": 30.0 }
  },
  "error": null
}
```

---

# 12. Edge Cases
- Tracking an order that has already been delivered (should cleanly inform the client it is closed).
- Driver location is missing or stale.

---

# 13. Testing Requirements
- E2E test fetching the tracking payload.

---

# 14. Observability / Logging
- Monitor polling frequency to ensure clients aren't hammering the server (rate limiting).

---

# 15. Security / Permissions
- Polling requires JWT of the order owner.

---

# 16. Performance Requirements
- Apply strict rate limiting to this route if polling is used (e.g., max 1 request per 5 seconds per client).

---

# 17. Deliverable Format
Standard backend implementation.

---

# 18. Completion Checklist
- [ ] Role check enforced
- [ ] Rate limiting applied (if polling)

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`.

---
End of File
