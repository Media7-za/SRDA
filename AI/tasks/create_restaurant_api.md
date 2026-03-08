# 1. Task Metadata

## Task Name
Create Restaurant API

## File Path
`/ai/tasks/create_restaurant_api.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the API endpoints to manage Restaurant profiles, including creation, updating details (like opening hours), and retrieving restaurant information.

---

# 3. Business Context

Restaurants are the core entity in the system. Even in an MVP with a single restaurant, the `restaurant_id` must exist to support future multi-tenant operations. 

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`
- `/ai/architecture.md`

---

# 5. Dependencies

- `create_auth_middleware.md` (for protecting the admin routes).
- Database `restaurants` table.

---

# 6. Scope

## In Scope
- Create `GET /restaurants` (list, public).
- Create `GET /restaurants/:id` (details, public).
- Create `POST /restaurants` (create, protected: admin).
- Create `PATCH /restaurants/:id` (update, protected: admin/staff).
- Create `PATCH /restaurants/:id/status` (toggle `is_active`, protected: admin/staff).

## Out of Scope
- Restaurant analytics endpoints.

---

# 7. Inputs
Example payload for update:
```json
{
  "name": "Phuket Thai",
  "phone": "+271234567",
  "address": "123 Main St",
  "isActive": true
}
```

---

# 8. Required Outputs
- `RestaurantController`
- `RestaurantService`
- Express/Fastify Routes

---

# 9. Acceptance Criteria
- Public can view active restaurants.
- Only admins can create a new restaurant.
- Only authorized staff/admins can update restaurant details or toggle active status.
- Responses use standard envelope.

---

# 10. Implementation Rules
- Ensure RBAC is applied securely using the previously built middleware.

---

# 11. API / Data Contracts
Standard envelope applies. 

---

# 12. Edge Cases
- Requesting an inactive restaurant as a public customer.
- Updating with invalid contact info.

---

# 13. Testing Requirements
- E2E tests for RBAC on the protected routes.

---

# 14. Observability / Logging
- Log when a restaurant's active status is toggled.

---

# 15. Security / Permissions
- `GET` routes are public.
- `POST`/`PATCH` routes require `admin` or specific `staff` role.

---

# 16. Performance Requirements
- Negligible for MVP.

---

# 17. Deliverable Format

**Summary**
Brief explanation of the implemented routes.

**Files Created/Updated**
Controllers, Services, Routes.

---

# 18. Completion Checklist
- [ ] RBAC applied correctly
- [ ] Active status toggling works
- [ ] Tests added

---

# 19. Agent Instruction

Execute this task strictly according to `backend_agent.md`.

---
End of File
