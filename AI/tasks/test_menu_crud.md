# 1. Task Metadata

## Task Name
Test Menu CRUD & Validation

## File Path
`/ai/tasks/test_menu_crud.md`

## Assigned Agent
- QA Agent

## Priority
- High

## Status
- Not Started

---

# 2. Objective

Verify that restaurant staff can safely manage categories and items through the UI without crashing the system, and that invalid data (negative prices) is rejected at both the UI and API layer.

---

# 3. Business Context

Accidents happen. Staff might type negative prices or attempt to delete categories actively in use. The system must degrade gracefully and guide them via UI validation.

---

# 4. Required Context Files

- `/ai/context.md`
- `/ai/agents/qa.md`

---

# 5. Dependencies

- `build_menu_management_ui.md`
- Backend Menu APIs.

---

# 6. Scope

## In Scope
- API Integration Test: Attempting to POST an item with a price of `-10`. Assert 400 Bad Request.
- E2E Web Test: Log in as admin, navigate to Menu Management, create a category, create an item with options inside it, edit the item, and then delete the category to assert the cascading rules (e.g., items become un-categorized or deleted depending on architecture).
- Verify that toggling `is_available` in the admin UI immediately hides the item when querying `GET /menu` (from the customer perspective).

## Out of Scope
- File uploads.

---

# 7. Inputs
- Admin JWT.

---

# 8. Required Outputs
- E2E Test script (`menu-management.spec.ts`).
- Backend Integration test (`menu-api-validation.test.ts`).

---

# 9. Acceptance Criteria
- Both frontend and backend reject invalid inputs (defense in depth).
- The public `GET /menu` correctly reflects changes made in the admin UI instantly.

---

# 10. Implementation Rules
- Test the `useFieldArray` dynamic form limits if any (e.g. max 50 options per item).

---

# 11. API / Data Contracts
Tests POST, PATCH, DELETE on `/menu/...` endpoints.

---

# 12. Edge Cases
- Deleting an item that is currently sitting in a random customer's active Cart session (Cart validation test should handle discovering the price/item changed, but this test ensures the DB delete is safe).

---

# 13. Testing Requirements
- E2E (Playwright/Cypress) and Integration (Jest).

---

# 14. Observability / Logging
- Test output.

---

# 15. Security / Permissions
- Verify `customer` token cannot POST to menu endpoints.

---

# 16. Performance Requirements
- Standard.

---

# 17. Deliverable Format
Test scripts.

---

# 18. Completion Checklist
- [ ] Negative prices blocked
- [ ] Public view syncs with Admin view
- [ ] Admin RBAC verified

---

# 19. Agent Instruction
You are the QA agent. Your job is to make sure data integrity is maintained when staff make mistakes in the dashboard.

---
End of File
