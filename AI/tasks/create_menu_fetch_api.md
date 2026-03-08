# 1. Task Metadata

## Task Name
Create Menu Fetch API

## File Path
`/ai/tasks/create_menu_fetch_api.md`

## Assigned Agent
- Backend Agent

## Priority
- Critical

## Status
- Not Started

---

# 2. Objective

Implement a high-performance, read-only API endpoint that fetches a restaurant's entire active menu (categories, items, and options) in a structured format suitable for the customer frontend UI.

---

# 3. Business Context

The menu fetch API is the most heavily trafficked endpoint in the system. It must be efficient and deliver data shaped exactly as the frontend needs it to render the customer experience immediately.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`

---

# 5. Dependencies

- `create_menu_item_api.md` (to populate data).

---

# 6. Scope

## In Scope
- Create `GET /restaurants/:restaurantId/menu`.
- Fetch all categories for the restaurant, ordered by `display_order`.
- Fetch all `is_available = true` menu items grouped under their respective categories.
- Include `menu_item_options` for each item.
- Exclude internal unneeded fields (e.g., created_at).

## Out of Scope
- Items that are currently unavailable (unless a query param `?includeUnavailable=true` is requested by staff).

---

# 7. Inputs
- Path param: `restaurantId`.

---

# 8. Required Outputs
- `MenuController`
- `MenuService`

---

# 9. Acceptance Criteria
- Endpoint returns a deeply nested JSON structure correctly grouping items by category.
- Only items where `is_available` is true are returned to public users.
- Query resolves quickly without N+1 query problems.

---

# 10. Implementation Rules
- Use Prisma's `include` feature strategically to fetch relations in a single query.
- Format the response payload efficiently.

---

# 11. API / Data Contracts
Example Response:
```json
{
  "success": true,
  "data": [
    {
      "id": "cat_1",
      "name": "Starters",
      "items": [
        {
          "id": "item_1",
          "name": "Spring Rolls",
          "price": 50.00,
          "options": []
        }
      ]
    }
  ],
  "error": null
}
```

---

# 12. Edge Cases
- A restaurant with no categories yet.
- Categories with no active items (should probably render as empty or not be returned, decide on standard approach).

---

# 13. Testing Requirements
- E2E test verifying structure and N+1 prevention.

---

# 14. Observability / Logging
- Monitor response times on this endpoint.

---

# 15. Security / Permissions
- Public route (no auth required).

---

# 16. Performance Requirements
- **Crucial:** Must not suffer from N+1 DB queries. Use appropriate joins/includes. Ensure caching headers are considered.

---

# 17. Deliverable Format
Standard template outputs.

---

# 18. Completion Checklist
- [ ] N+1 queries prevented
- [ ] Only available items returned

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`. Performance is key here.

---
End of File
