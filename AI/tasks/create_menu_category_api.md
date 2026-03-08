# 1. Task Metadata

## Task Name
Create Menu Category API

## File Path
`/ai/tasks/create_menu_category_api.md`

## Assigned Agent
- Backend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the administrative CRUD operations for `menu_categories` to allow restaurant staff to organize their menu.

---

# 3. Business Context

Categories (e.g., "Starters", "Mains", "Drinks") organize the menu for the customer. Proper management APIs are needed before items can be added.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agent_rules.md`
- `/ai/agents/backend_agent.md`

---

# 5. Dependencies

- `create_restaurant_api.md` (Need a valid `restaurant_id`).
- Auth middleware for RBAC.

---

# 6. Scope

## In Scope
- Create `POST /restaurants/:restaurantId/categories` (create).
- Create `PATCH /restaurants/:restaurantId/categories/:id` (update name, display_order).
- Create `DELETE /restaurants/:restaurantId/categories/:id` (delete).
- Manage `display_order` for sorting.

## Out of Scope
- Fetching categories for the public menu (handled in Fetch API task).

---

# 7. Inputs
Example payload:
```json
{
  "name": "Starters",
  "displayOrder": 1
}
```

---

# 8. Required Outputs
- `MenuCategoryController`
- `MenuCategoryService`

---

# 9. Acceptance Criteria
- Categories are successfully linked to a specific restaurant.
- Deleting a category updates its child items according to the DB schema rules (`SET NULL`).
- Only authorized staff/admins can perform these actions.

---

# 10. Implementation Rules
- Validate that the user has permission to manage the specified `restaurantId`.

---

# 11. API / Data Contracts
Standard envelope applies.

---

# 12. Edge Cases
- Deleting a category that currently has active menu items.

---

# 13. Testing Requirements
- Test the cascading / nullifying effect on menu items when a category is deleted.

---

# 14. Observability / Logging
- Log category deletions.

---

# 15. Security / Permissions
- All routes require `admin` or `staff` role.

---

# 16. Performance Requirements
- Standard.

---

# 17. Deliverable Format
Standard template outputs.

---

# 18. Completion Checklist
- [ ] DB deletion rules respected
- [ ] RBAC enforced

---

# 19. Agent Instruction
Execute this task strictly according to `backend_agent.md`.

---
End of File
