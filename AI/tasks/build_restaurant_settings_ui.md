# 1. Task Metadata

## Task Name
Build Restaurant Settings UI

## File Path
`/ai/tasks/build_restaurant_settings_ui.md`

## Assigned Agent
- Frontend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the forms allowing owners to modify their core restaurant details (Name, Address, Phone) and heavily control their operational state (Online/Offline master switch, Opening Hours).

---

# 3. Business Context

If the kitchen is overwhelmed, the manager must be able to hit "Go Offline" instantly via this page to stop the influx of online orders. This is a critical business safety valve.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/frontend_agent.md`

---

# 5. Dependencies

- `create_restaurant_api.md` (Specifically the `is_active` toggle PATCH).

---

# 6. Scope

## In Scope
- Create `/app/admin/settings/page.tsx`.
- Big red "Store is Online / Offline" toggle switch prominently displayed.
- Form to update basic contact details (`PATCH /restaurants/:id`).
- Form to define standard opening hours (e.g., Monday: 09:00 - 17:00).

## Out of Scope
- Complex payout routing configurations (e.g., editing Stripe Connect details inline).

---

# 7. Inputs
- Switch toggles.
- Standard inputs.

---

# 8. Required Outputs
- `RestaurantSettingsPage`.
- `OperatingHoursForm`.

---

# 9. Acceptance Criteria
- Toggling the primary Online/Offline switch provides immediate visual feedback and persists via optimistic API calls.
- Opening hours form validates correctly (close time cannot be before open time).

---

# 10. Implementation Rules
- The Online/Offline switch is the most critical button on this UI. Make it massive and sticky if possible.

---

# 11. API / Data Contracts
Consumes Restaurant API.

---

# 12. Edge Cases
- Hitting Offline while customers have carts active (Backend normally handles rejecting checkout, but the UI must be clear).

---

# 13. Testing Requirements
- E2E testing the offline toggle.

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
Next.js page and hooks.

---

# 18. Completion Checklist
- [ ] Master toggle functional
- [ ] Opening hours validated
- [ ] Contact details syncing

---

# 19. Agent Instruction
Execute strictly according to `frontend_agent.md`.

---
End of File
