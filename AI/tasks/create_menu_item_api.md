# 1. Task Metadata

## Task Name
Create Menu Item API

## File Path
`/ai/tasks/create_menu_item_api.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the administrative CRUD operations for `menu_items` and `menu_item_options`, providing staff the tools to manage pricing, availability, and customizations.

---

# 3. Business Context

Menu items are the products sold. They frequently change availability and price. The API must handle these updates cleanly, especially regarding options/modifiers.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`

---

# 5. Dependencies

- `create_menu_category_api.md`

---

# 6. Scope

## In Scope
- Create `POST /restaurants/:restaurantId/items`.
- Create `PATCH /restaurants/:restaurantId/items/:id` (update details, toggle `is_available`).
- Create `DELETE /restaurants/:restaurantId/items/:id` (soft delete or hard delete depending on schema DB rules).
- Support nested creation/updating of `menu_item_options`.

## Out of Scope
- Public fetching of items.

---

# 7. Inputs
Example payload:
```json
{
  "categoryId": "uuid",
  "name": "Pad Thai",
  "description": "Noodles",
  "price": 120.00,
  "isAvailable": true,
  "options": [
    { "name": "Extra Tofu", "price": 15.00 }
  ]
}
```

---

# 8. Required Outputs
- `MenuItemController`
- `MenuItemService`

---

# 9. Acceptance Criteria
- Items can be created with or without options.
- Availability toggle works.
- Prices are securely stored and validated.
- Staff RBAC enforced securely.

---

# 10. Implementation Rules
- Ensure amounts (prices) are handled according to your DB precision choices.

---

# 11. API / Data Contracts
Standard envelope applies.

---

# 12. Edge Cases
- Validation on negative prices.
- Updating an item's category.

---

# 13. Testing Requirements
- Unit tests for validation logic.
- Integration tests for nested relation updates in Prisma.

---

# 14. Observability / Logging
- Log major menu changes.

---

# 15. Security / Permissions
- All routes require `admin` or `staff`.

---

# 16. Performance Requirements
- Standard.

---

# 17. Deliverable Format
Standard template outputs.

---

# 18. Completion Checklist
- [ ] Nested options supported
- [ ] Validations active

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`.

---
End of File
