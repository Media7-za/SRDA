# 1. Task Metadata

## Task Name
Build Menu Management UI

## File Path
`/ai/tasks/build_menu_management_ui.md`

## Assigned Agent
- Frontend Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Implement the administrative interface for staff to create, update, reorder categories, and manage menu items (including options, prices, and availability).

---

# 3. Business Context

Prices change, ingredients run out. Staff need a deeply intuitive way to toggle availability instantly without needing to call IT support.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/frontend_agent.md`

---

# 5. Dependencies

- `create_menu_category_api.md`
- `create_menu_item_api.md`

---

# 6. Scope

## In Scope
- Create `/app/admin/menu/page.tsx`.
- Create a Category Sidebar or Tab list to navigate the menu structure.
- Add "Create Category" / "Edit Category" Modals.
- Display a table or grid of items within the selected category.
- Add "Create Item" / "Edit Item" Modals (Form must handle mapping nested `menu_item_options` efficiently).
- Add a fast one-click toggle switch for `is_available` on every item row.

## Out of Scope
- Uploading images (MVP relies on URL inputs or backend handling this separately).

---

# 7. Inputs
- Forms (RHF / Zod).

---

# 8. Required Outputs
- `AdminMenuPage` component.
- `CategoryForm` modal.
- `ItemForm` modal (complex, handling nested dynamic option arrays).

---

# 9. Acceptance Criteria
- Modals successfully populate data for updates, and clear data for creates.
- `useFieldArray` (from `react-hook-form`) is used to allow staff to add/remove `options` dynamically.
- Toggling `is_available` sends a `PATCH` request immediately and updates optimistically.

---

# 10. Implementation Rules
- Data table components from Shadcn are highly recommended here for clean layout.

---

# 11. API / Data Contracts
Consumes the POST/PATCH/DELETE methods from the Menu APIs.

---

# 12. Edge Cases
- Deleting a category with active items warning.
- Forgetting to save prices on an option.

---

# 13. Testing Requirements
- E2E or Component test specifically for the `useFieldArray` options addition/deletion inside the `ItemForm`.

---

# 14. Observability / Logging
- None.

---

# 15. Security / Permissions
- Admin/Staff route guard.

---

# 16. Performance Requirements
- Standard admin forms.

---

# 17. Deliverable Format
Next.js page and complex modal components.

---

# 18. Completion Checklist
- [ ] Instant toggle for availability
- [ ] `useFieldArray` implemented for options
- [ ] Category tree manageable

---

# 19. Agent Instruction
Execute strictly according to `frontend_agent.md`. Ensure that form validations prevent users from submitting bad data (e.g. negative prices).

---
End of File
